import { Injectable, NotFoundException } from '@nestjs/common';
import { Role, UserStatus } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(page: number, limit: number, role?: Role) {
    const skip = (page - 1) * limit;
    const where = role ? { role } : {};

    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        select: {
          id: true,
          phone: true,
          email: true,
          role: true,
          status: true,
          createdAt: true,
          clientProfile: { select: { name: true, avatarUrl: true } },
          merchantProfile: { select: { businessName: true, isVerified: true } },
          driverProfile: { select: { name: true, isAvailable: true, ratingAvg: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.user.count({ where }),
    ]);

    return { users, total, page, limit };
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        phone: true,
        email: true,
        role: true,
        status: true,
        createdAt: true,
        updatedAt: true,
        clientProfile: true,
        merchantProfile: true,
        driverProfile: true,
      },
    });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async setStatus(id: string, status: UserStatus) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');

    return this.prisma.user.update({
      where: { id },
      data: { status },
      select: { id: true, phone: true, role: true, status: true },
    });
  }
}
