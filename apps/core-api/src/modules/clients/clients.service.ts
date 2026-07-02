import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateClientProfileDto } from './dto/create-client-profile.dto';
import { UpdateClientProfileDto } from './dto/update-client-profile.dto';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateAddressDto } from './dto/update-address.dto';

@Injectable()
export class ClientsService {
  constructor(private readonly prisma: PrismaService) {}

  async createProfile(userId: string, dto: CreateClientProfileDto) {
    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });
    if (user.role !== Role.CLIENT) {
      throw new ForbiddenException('Only CLIENT users can create a client profile');
    }

    const existing = await this.prisma.clientProfile.findUnique({ where: { userId } });
    if (existing) throw new ConflictException('Client profile already exists');

    return this.prisma.clientProfile.create({
      data: { userId, name: dto.name, avatarUrl: dto.avatarUrl },
    });
  }

  async getMyProfile(userId: string) {
    const profile = await this.prisma.clientProfile.findUnique({
      where: { userId },
      include: { user: { select: { id: true, phone: true, email: true, status: true } } },
    });
    if (!profile) throw new NotFoundException('Client profile not found');
    return profile;
  }

  async updateMyProfile(userId: string, dto: UpdateClientProfileDto) {
    await this.getMyProfile(userId);
    return this.prisma.clientProfile.update({
      where: { userId },
      data: { name: dto.name, avatarUrl: dto.avatarUrl },
    });
  }

  // ─── Addresses ───────────────────────────────────────────────────────────────

  async getMyAddresses(userId: string) {
    return this.prisma.clientAddress.findMany({
      where: { userId },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });
  }

  async addAddress(userId: string, dto: CreateAddressDto) {
    return this.prisma.$transaction(async (tx) => {
      // First address is always default; otherwise respect dto.isDefault
      const count = await tx.clientAddress.count({ where: { userId } });
      const shouldBeDefault = dto.isDefault || count === 0;

      if (shouldBeDefault) {
        await tx.clientAddress.updateMany({
          where: { userId, isDefault: true },
          data: { isDefault: false },
        });
      }

      return tx.clientAddress.create({
        data: {
          userId,
          label: dto.label,
          address: dto.address,
          latitude: dto.latitude,
          longitude: dto.longitude,
          isDefault: shouldBeDefault,
        },
      });
    });
  }

  async updateAddress(userId: string, addressId: string, dto: UpdateAddressDto) {
    const address = await this.prisma.clientAddress.findUnique({ where: { id: addressId } });
    if (!address || address.userId !== userId) {
      throw new NotFoundException('Address not found');
    }

    return this.prisma.$transaction(async (tx) => {
      if (dto.isDefault) {
        await tx.clientAddress.updateMany({
          where: { userId, isDefault: true },
          data: { isDefault: false },
        });
      }
      return tx.clientAddress.update({
        where: { id: addressId },
        data: {
          label: dto.label,
          address: dto.address,
          latitude: dto.latitude,
          longitude: dto.longitude,
          isDefault: dto.isDefault,
        },
      });
    });
  }

  async deleteAddress(userId: string, addressId: string) {
    const address = await this.prisma.clientAddress.findUnique({ where: { id: addressId } });
    if (!address || address.userId !== userId) {
      throw new NotFoundException('Address not found');
    }
    await this.prisma.clientAddress.delete({ where: { id: addressId } });
    return { message: 'Address deleted' };
  }

  async setDefaultAddress(userId: string, addressId: string) {
    const address = await this.prisma.clientAddress.findUnique({ where: { id: addressId } });
    if (!address || address.userId !== userId) {
      throw new NotFoundException('Address not found');
    }

    return this.prisma.$transaction(async (tx) => {
      await tx.clientAddress.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      });
      return tx.clientAddress.update({
        where: { id: addressId },
        data: { isDefault: true },
      });
    });
  }

  // ─── Admin ────────────────────────────────────────────────────────────────────

  async findAll(page: number, limit: number) {
    const skip = (page - 1) * limit;
    const [clients, total] = await Promise.all([
      this.prisma.clientProfile.findMany({
        skip,
        take: limit,
        include: { user: { select: { id: true, phone: true, email: true, status: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.clientProfile.count(),
    ]);
    return { clients, total, page, limit };
  }

  async suspend(userId: string) {
    const profile = await this.prisma.clientProfile.findUnique({ where: { userId } });
    if (!profile) throw new NotFoundException('Client not found');
    return this.prisma.user.update({
      where: { id: userId },
      data: { status: 'SUSPENDED' },
      select: { id: true, phone: true, status: true },
    });
  }
}
