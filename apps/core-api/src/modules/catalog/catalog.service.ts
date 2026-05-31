import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class CatalogService {
  constructor(private readonly prisma: PrismaService) {}

  async getHome() {
    const [categories, featuredStores] = await Promise.all([
      this.prisma.category.findMany({
        where: { isActive: true },
        select: { id: true, name: true, slug: true, iconUrl: true },
        orderBy: { name: 'asc' },
      }),
      this.prisma.store.findMany({
        where: { isActive: true },
        take: 10,
        select: {
          id: true,
          name: true,
          description: true,
          address: true,
          logoUrl: true,
          coverUrl: true,
          ratingAvg: true,
          ratingCount: true,
          openingHours: true,
          category: { select: { id: true, name: true, slug: true, iconUrl: true } },
        },
        orderBy: { ratingAvg: 'desc' },
      }),
    ]);

    return { categories, featuredStores };
  }

  async search(q: string, page: number, limit: number) {
    const trimmed = q?.trim();
    if (!trimmed) return { query: q, stores: [], products: [], page, limit };

    const skip = (page - 1) * limit;
    const contains = trimmed;
    const mode = 'insensitive' as const;

    const [stores, products] = await Promise.all([
      this.prisma.store.findMany({
        where: {
          isActive: true,
          OR: [
            { name: { contains, mode } },
            { description: { contains, mode } },
          ],
        },
        skip,
        take: limit,
        select: {
          id: true,
          name: true,
          description: true,
          address: true,
          logoUrl: true,
          ratingAvg: true,
          ratingCount: true,
          category: { select: { id: true, name: true, slug: true } },
        },
        orderBy: { ratingAvg: 'desc' },
      }),
      this.prisma.product.findMany({
        where: {
          isActive: true,
          isAvailable: true,
          OR: [
            { name: { contains, mode } },
            { description: { contains, mode } },
          ],
        },
        skip,
        take: limit,
        select: {
          id: true,
          name: true,
          description: true,
          price: true,
          imageUrl: true,
          store: { select: { id: true, name: true } },
        },
        orderBy: { name: 'asc' },
      }),
    ]);

    return { query: q, stores, products, page, limit };
  }

  async getStoresByCategory(categoryId: string, page: number, limit: number) {
    const skip = (page - 1) * limit;
    const where = { isActive: true, categoryId };

    const [stores, total] = await Promise.all([
      this.prisma.store.findMany({
        where,
        skip,
        take: limit,
        select: {
          id: true,
          name: true,
          description: true,
          address: true,
          logoUrl: true,
          ratingAvg: true,
          ratingCount: true,
          openingHours: true,
          category: { select: { id: true, name: true, slug: true } },
        },
        orderBy: { ratingAvg: 'desc' },
      }),
      this.prisma.store.count({ where }),
    ]);

    return { stores, total, page, limit };
  }
}
