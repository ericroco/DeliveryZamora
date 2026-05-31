import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateMerchantProfileDto } from './dto/create-merchant-profile.dto';
import { UpdateMerchantProfileDto } from './dto/update-merchant-profile.dto';

@Injectable()
export class MerchantsService {
  constructor(private readonly prisma: PrismaService) {}

  async createProfile(userId: string, dto: CreateMerchantProfileDto) {
    const existing = await this.prisma.merchantProfile.findUnique({
      where: { userId },
    });

    if (existing) {
      throw new ConflictException('Merchant profile already exists');
    }

    const user = await this.prisma.user.findUniqueOrThrow({ where: { id: userId } });

    if (user.role !== 'MERCHANT') {
      throw new ForbiddenException('Only MERCHANT users can create a merchant profile');
    }

    return this.prisma.merchantProfile.create({
      data: {
        userId,
        businessName: dto.businessName,
        description: dto.description,
        address: dto.address,
        phone: dto.phone,
        ruc: dto.ruc,
        openingHours: dto.openingHours,
      },
    });
  }

  async getMyProfile(userId: string) {
    const profile = await this.prisma.merchantProfile.findUnique({
      where: { userId },
      include: {
        user: {
          select: { id: true, phone: true, email: true, status: true },
        },
      },
    });

    if (!profile) {
      throw new NotFoundException('Merchant profile not found');
    }

    return profile;
  }

  async updateMyProfile(userId: string, dto: UpdateMerchantProfileDto) {
    await this.getMyProfile(userId);

    return this.prisma.merchantProfile.update({
      where: { userId },
      data: {
        businessName: dto.businessName,
        description: dto.description,
        address: dto.address,
        phone: dto.phone,
        ruc: dto.ruc,
        openingHours: dto.openingHours,
      },
    });
  }

  async findAll(page: number, limit: number) {
    const skip = (page - 1) * limit;

    const [merchants, total] = await Promise.all([
      this.prisma.merchantProfile.findMany({
        skip,
        take: limit,
        include: {
          user: {
            select: { id: true, phone: true, email: true, status: true },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.merchantProfile.count(),
    ]);

    return { merchants, total, page, limit };
  }

  async findOne(userId: string) {
    const profile = await this.prisma.merchantProfile.findUnique({
      where: { userId },
      include: {
        user: {
          select: { id: true, phone: true, email: true, status: true },
        },
      },
    });

    if (!profile) {
      throw new NotFoundException('Merchant not found');
    }

    return profile;
  }

  async verify(userId: string) {
    await this.findOne(userId);

    return this.prisma.merchantProfile.update({
      where: { userId },
      data: {
        isVerified: true,
        verifiedAt: new Date(),
      },
    });
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
