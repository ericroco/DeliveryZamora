import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus, Role } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateDriverProfileDto } from './dto/create-driver-profile.dto';
import { UpdateDriverProfileDto } from './dto/update-driver-profile.dto';
import { RateDriverDto } from './dto/rate-driver.dto';

@Injectable()
export class DriversService {
  constructor(private readonly prisma: PrismaService) {}

  async createProfile(userId: string, dto: CreateDriverProfileDto) {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    if (user.role !== Role.DRIVER) {
      throw new ForbiddenException('Only DRIVER users can create a driver profile');
    }

    const existing = await this.prisma.driverProfile.findUnique({ where: { userId } });
    if (existing) throw new ConflictException('Driver profile already exists');

    const cedulaTaken = await this.prisma.driverProfile.findUnique({
      where: { cedula: dto.cedula },
    });
    if (cedulaTaken) throw new ConflictException('Cedula already registered');

    return this.prisma.driverProfile.create({
      data: {
        userId,
        name: dto.name,
        cedula: dto.cedula,
        vehicleType: dto.vehicleType,
        plate: dto.plate,
      },
    });
  }

  async getMyProfile(userId: string) {
    const profile = await this.prisma.driverProfile.findUnique({
      where: { userId },
      include: { user: { select: { id: true, phone: true, email: true, status: true } } },
    });
    if (!profile) throw new NotFoundException('Driver profile not found');
    return profile;
  }

  async updateMyProfile(userId: string, dto: UpdateDriverProfileDto) {
    await this.getMyProfile(userId);

    return this.prisma.driverProfile.update({
      where: { userId },
      data: {
        name: dto.name,
        vehicleType: dto.vehicleType,
        plate: dto.plate,
      },
    });
  }

  async setAvailability(userId: string, isAvailable: boolean) {
    await this.getMyProfile(userId);

    return this.prisma.driverProfile.update({
      where: { userId },
      data: { isAvailable },
      select: { userId: true, name: true, isAvailable: true },
    });
  }

  async getAvailableOrders(page: number, limit: number) {
    const skip = (page - 1) * limit;
    const where = { status: OrderStatus.READY, driverId: null };

    const [orders, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        skip,
        take: limit,
        include: {
          store: { select: { id: true, name: true, address: true } },
          items: { select: { quantity: true, product: { select: { name: true } } } },
        },
        orderBy: { createdAt: 'asc' },
      }),
      this.prisma.order.count({ where }),
    ]);

    return { orders, total, page, limit };
  }

  async rateDriver(orderId: string, dto: RateDriverDto, clientId: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (order.clientId !== clientId) throw new ForbiddenException('Not your order');
    if (order.status !== OrderStatus.DELIVERED) {
      throw new BadRequestException('Can only rate after delivery');
    }
    if (!order.driverId) throw new BadRequestException('No driver assigned to this order');
    if (order.driverRated) throw new BadRequestException('Driver already rated for this order');

    const result = await this.prisma.$transaction(async (tx) => {
      const driver = await tx.driverProfile.findUnique({ where: { userId: order.driverId! } });
      if (!driver) throw new NotFoundException('Driver profile not found');

      const newCount = driver.ratingCount + 1;
      const newAvg = (Number(driver.ratingAvg) * driver.ratingCount + dto.rating) / newCount;
      const roundedAvg = Math.round(newAvg * 100) / 100;

      await tx.driverProfile.update({
        where: { userId: order.driverId! },
        data: { ratingAvg: roundedAvg, ratingCount: newCount },
      });

      await tx.driverRating.create({
        data: {
          orderId,
          driverId: order.driverId!,
          clientId,
          rating: dto.rating,
          comment: dto.comment,
        },
      });

      await tx.order.update({
        where: { id: orderId },
        data: { driverRated: true },
      });

      return { userId: order.driverId!, name: driver.name, ratingAvg: roundedAvg, ratingCount: newCount };
    });

    return result;
  }

  async findAll(page: number, limit: number) {
    const skip = (page - 1) * limit;

    const [drivers, total] = await Promise.all([
      this.prisma.driverProfile.findMany({
        skip,
        take: limit,
        include: { user: { select: { id: true, phone: true, email: true, status: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.driverProfile.count(),
    ]);

    return { drivers, total, page, limit };
  }

  async findOne(userId: string) {
    const profile = await this.prisma.driverProfile.findUnique({
      where: { userId },
      include: { user: { select: { id: true, phone: true, email: true, status: true } } },
    });
    if (!profile) throw new NotFoundException('Driver not found');
    return profile;
  }

  async suspend(userId: string) {
    await this.findOne(userId);
    return this.prisma.user.update({
      where: { id: userId },
      data: { status: 'SUSPENDED' },
      select: { id: true, phone: true, status: true },
    });
  }
}
