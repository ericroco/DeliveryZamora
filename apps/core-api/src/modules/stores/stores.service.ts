import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';
import { Role } from '@prisma/client';

@Injectable()
export class StoresService {
  constructor(private readonly prisma: PrismaService) {}

  async create(merchantId: string, dto: CreateStoreDto) {
    await this.prisma.category.findUniqueOrThrow({
      where: { id: dto.categoryId },
    }).catch(() => {
      throw new NotFoundException('Category not found');
    });

    return this.prisma.store.create({
      data: {
        merchantId,
        categoryId: dto.categoryId,
        name: dto.name,
        description: dto.description,
        address: dto.address,
        phone: dto.phone,
        latitude: dto.latitude,
        longitude: dto.longitude,
        openingHours: dto.openingHours,
      },
      include: { category: true },
    });
  }

  async findAll(page: number, limit: number, categoryId?: string, search?: string) {
    const skip = (page - 1) * limit;
    const where = {
      isActive: true,
      ...(categoryId ? { categoryId } : {}),
      ...(search
        ? { OR: [{ name: { contains: search, mode: 'insensitive' as const } }, { description: { contains: search, mode: 'insensitive' as const } }] }
        : {}),
    };

    const [stores, total] = await Promise.all([
      this.prisma.store.findMany({
        where,
        skip,
        take: limit,
        include: {
          category: { select: { id: true, name: true, slug: true } },
          merchant: { select: { businessName: true, isVerified: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.store.count({ where }),
    ]);

    return { stores, total, page, limit };
  }

  async findOne(id: string) {
    const store = await this.prisma.store.findUnique({
      where: { id },
      include: {
        category: true,
        merchant: {
          select: {
            businessName: true,
            isVerified: true,
            user: { select: { phone: true } },
          },
        },
      },
    });

    if (!store) {
      throw new NotFoundException('Store not found');
    }

    return store;
  }

  async findMine(merchantId: string) {
    return this.prisma.store.findMany({
      where: { merchantId },
      include: { category: { select: { id: true, name: true, slug: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async update(
    id: string,
    dto: UpdateStoreDto,
    requesterId: string,
    requesterRole: Role,
  ) {
    const store = await this.findOne(id);

    if (requesterRole !== 'ADMIN' && store.merchantId !== requesterId) {
      throw new ForbiddenException('You do not own this store');
    }

    return this.prisma.store.update({
      where: { id },
      data: {
        name: dto.name,
        description: dto.description,
        address: dto.address,
        phone: dto.phone,
        latitude: dto.latitude,
        longitude: dto.longitude,
        openingHours: dto.openingHours,
        isActive: dto.isActive,
        ...(dto.categoryId ? { categoryId: dto.categoryId } : {}),
      },
      include: { category: true },
    });
  }

  async remove(id: string, requesterId: string, requesterRole: Role) {
    const store = await this.findOne(id);

    if (requesterRole !== 'ADMIN' && store.merchantId !== requesterId) {
      throw new ForbiddenException('You do not own this store');
    }

    return this.prisma.store.update({
      where: { id },
      data: { isActive: false },
    });
  }
}
