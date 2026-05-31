import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { DiscountType, Role } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreatePromotionDto } from './dto/create-promotion.dto';

@Injectable()
export class PromotionsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreatePromotionDto, requesterId: string, requesterRole: Role) {
    if (requesterRole === Role.MERCHANT) {
      if (!dto.storeId) throw new BadRequestException('MERCHANT must specify storeId');
      const store = await this.prisma.store.findUnique({ where: { id: dto.storeId } });
      if (!store || store.merchantId !== requesterId) {
        throw new ForbiddenException('Not your store');
      }
    }

    const existing = await this.prisma.promotion.findUnique({ where: { code: dto.code } });
    if (existing) throw new ConflictException('Promo code already exists');

    return this.prisma.promotion.create({
      data: {
        code: dto.code.toUpperCase(),
        name: dto.name,
        discountType: dto.discountType,
        discountValue: dto.discountValue,
        minOrderAmount: dto.minOrderAmount,
        maxUses: dto.maxUses,
        expiresAt: dto.expiresAt ? new Date(dto.expiresAt) : undefined,
        storeId: dto.storeId,
      },
    });
  }

  async validate(code: string, storeId: string, orderAmount: number) {
    const promo = await this.prisma.promotion.findUnique({
      where: { code: code.toUpperCase() },
    });

    if (!promo || !promo.isActive) {
      throw new BadRequestException('Invalid or inactive promo code');
    }
    if (promo.expiresAt && promo.expiresAt < new Date()) {
      throw new BadRequestException('Promo code has expired');
    }
    if (promo.storeId && promo.storeId !== storeId) {
      throw new BadRequestException('Promo code not valid for this store');
    }
    if (promo.minOrderAmount && orderAmount < Number(promo.minOrderAmount)) {
      throw new BadRequestException(
        `Minimum order amount is $${promo.minOrderAmount} for this promo`,
      );
    }
    if (promo.maxUses !== null && promo.usedCount >= promo.maxUses) {
      throw new BadRequestException('Promo code usage limit reached');
    }

    const discountAmount =
      promo.discountType === DiscountType.PERCENTAGE
        ? Math.min((orderAmount * Number(promo.discountValue)) / 100, orderAmount)
        : Math.min(Number(promo.discountValue), orderAmount);

    return {
      promotionId: promo.id,
      discountAmount: Math.round(discountAmount * 100) / 100,
      finalAmount: Math.round((orderAmount - discountAmount) * 100) / 100,
    };
  }

  async consume(promotionId: string, orderId: string, userId: string, discountApplied: number) {
    await this.prisma.$transaction([
      this.prisma.promotion.update({
        where: { id: promotionId },
        data: { usedCount: { increment: 1 } },
      }),
      this.prisma.promoUsage.create({
        data: { promotionId, orderId, userId, discountApplied },
      }),
    ]);
  }

  async findAll(page: number, limit: number, requesterId: string, requesterRole: Role) {
    const skip = (page - 1) * limit;

    let where = {};
    if (requesterRole === Role.MERCHANT) {
      const stores = await this.prisma.store.findMany({
        where: { merchantId: requesterId },
        select: { id: true },
      });
      where = { storeId: { in: stores.map((s) => s.id) } };
    }

    const [promotions, total] = await Promise.all([
      this.prisma.promotion.findMany({
        where,
        skip,
        take: limit,
        include: { store: { select: { id: true, name: true } } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.promotion.count({ where }),
    ]);
    return { promotions, total, page, limit };
  }

  async deactivate(id: string, requesterId: string, requesterRole: Role) {
    const promo = await this.prisma.promotion.findUnique({
      where: { id },
      include: { store: { select: { merchantId: true } } },
    });
    if (!promo) throw new NotFoundException('Promotion not found');

    if (requesterRole === Role.MERCHANT) {
      if (!promo.storeId || promo.store?.merchantId !== requesterId) {
        throw new ForbiddenException('Not your promotion');
      }
    }

    return this.prisma.promotion.update({ where: { id }, data: { isActive: false } });
  }
}
