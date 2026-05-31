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
