import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus, Role } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { UpdateLocationDto } from './dto/update-location.dto';

type Requester = { id: string; role: Role };

@Injectable()
export class DeliveryService {
  constructor(private readonly prisma: PrismaService) {}

  async updateLocation(orderId: string, dto: UpdateLocationDto, requester: Requester) {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: { store: { select: { merchantId: true } } },
    });
    if (!order) throw new NotFoundException('Order not found');

    if (requester.role !== Role.ADMIN && order.driverId !== requester.id) {
      throw new ForbiddenException('Only the assigned driver can update location');
    }

    if (order.status !== OrderStatus.PICKED_UP) {
      throw new ForbiddenException('Location updates only allowed while order is PICKED_UP');
    }

    return this.prisma.order.update({
      where: { id: orderId },
      data: {
        driverLat: dto.lat,
        driverLng: dto.lng,
        locationUpdatedAt: new Date(),
      },
      select: {
        id: true,
        driverLat: true,
        driverLng: true,
        locationUpdatedAt: true,
        status: true,
      },
    });
  }

  async getLocation(orderId: string, requester: Requester) {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: { store: { select: { merchantId: true } } },
    });
    if (!order) throw new NotFoundException('Order not found');

    const canAccess =
      requester.role === Role.ADMIN ||
      order.clientId === requester.id ||
      order.store.merchantId === requester.id ||
      order.driverId === requester.id;

    if (!canAccess) throw new ForbiddenException('Access denied');

    return {
      orderId: order.id,
      status: order.status,
      driverLat: order.driverLat,
      driverLng: order.driverLng,
      locationUpdatedAt: order.locationUpdatedAt,
    };
  }
}
