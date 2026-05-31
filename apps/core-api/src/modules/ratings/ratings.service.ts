import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RateStoreDto } from './dto/rate-store.dto';

@Injectable()
export class RatingsService {
  constructor(private readonly prisma: PrismaService) {}

  async rateStore(orderId: string, dto: RateStoreDto, clientId: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');
    if (order.clientId !== clientId) throw new ForbiddenException('Not your order');
    if (order.status !== OrderStatus.DELIVERED) {
      throw new BadRequestException('Can only rate after delivery');
    }
    if (order.storeRated) throw new ConflictException('Store already rated for this order');

    const storeRating = await this.prisma.$transaction(async (tx) => {
      const store = await tx.store.findUnique({ where: { id: order.storeId } });
      if (!store) throw new NotFoundException('Store not found');

      const newCount = store.ratingCount + 1;
      const newAvg = (Number(store.ratingAvg) * store.ratingCount + dto.rating) / newCount;

      await tx.store.update({
        where: { id: order.storeId },
        data: { ratingAvg: Math.round(newAvg * 100) / 100, ratingCount: newCount },
      });

      const rating = await tx.storeRating.create({
        data: {
          orderId,
          storeId: order.storeId,
          clientId,
          rating: dto.rating,
          comment: dto.comment,
        },
      });

      await tx.order.update({
        where: { id: orderId },
        data: { storeRated: true },
      });

      return rating;
    });

    return storeRating;
  }

  async getStoreRatings(storeId: string, page: number, limit: number) {
    const store = await this.prisma.store.findUnique({ where: { id: storeId } });
    if (!store) throw new NotFoundException('Store not found');

    const skip = (page - 1) * limit;
    const [ratings, total] = await Promise.all([
      this.prisma.storeRating.findMany({
        where: { storeId },
        skip,
        take: limit,
        include: { client: { select: { id: true, clientProfile: { select: { name: true } } } } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.storeRating.count({ where: { storeId } }),
    ]);

    return {
      ratings,
      total,
      page,
      limit,
      summary: { ratingAvg: store.ratingAvg, ratingCount: store.ratingCount },
    };
  }
}

