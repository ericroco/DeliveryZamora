import { Injectable } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class AnalyticsService {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary() {
    const [totalUsers, totalOrders, totalStores, revenueResult, pendingOrders] =
      await Promise.all([
        this.prisma.user.count(),
        this.prisma.order.count(),
        this.prisma.store.count({ where: { isActive: true } }),
        this.prisma.order.aggregate({
          _sum: { totalAmount: true },
          where: { status: OrderStatus.DELIVERED },
        }),
        this.prisma.order.count({ where: { status: OrderStatus.PENDING } }),
      ]);

    return {
      totalUsers,
      totalOrders,
      totalStores,
      totalRevenue: revenueResult._sum.totalAmount ?? 0,
      pendingOrders,
    };
  }

  async getOrdersByStatus() {
    const statuses = Object.values(OrderStatus);
    const counts = await Promise.all(
      statuses.map((status) =>
        this.prisma.order.count({ where: { status } }).then((count) => ({ status, count })),
      ),
    );
    return counts;
  }

  async getRevenueByPeriod(days: number) {
    const safeDays = Math.min(Math.max(1, days), 365);
    const from = new Date();
    from.setDate(from.getDate() - safeDays);

    const orders = await this.prisma.order.findMany({
      where: { status: OrderStatus.DELIVERED, createdAt: { gte: from } },
      select: { totalAmount: true, createdAt: true },
      orderBy: { createdAt: 'asc' },
    });

    const grouped: Record<string, number> = {};
    for (const order of orders) {
      const day = order.createdAt.toISOString().split('T')[0];
      grouped[day] = (grouped[day] ?? 0) + Number(order.totalAmount);
    }

    return Object.entries(grouped).map(([date, revenue]) => ({ date, revenue }));
  }

  async getTopStores(limit: number) {
    const safeLimit = Math.min(Math.max(1, limit), 50);
    const stores = await this.prisma.store.findMany({
      where: { isActive: true },
      select: {
        id: true,
        name: true,
        ratingAvg: true,
        ratingCount: true,
        _count: { select: { orders: true } },
      },
      orderBy: { orders: { _count: 'desc' } },
      take: safeLimit,
    });
    return stores;
  }

  async getTopDrivers(limit: number) {
    const safeLimit = Math.min(Math.max(1, limit), 50);
    const drivers = await this.prisma.driverProfile.findMany({
      select: {
        userId: true,
        name: true,
        ratingAvg: true,
        ratingCount: true,
        _count: { select: { orders: true } },
      },
      orderBy: { ratingAvg: 'desc' },
      take: safeLimit,
    });
    return drivers;
  }

  async getUsersByRole() {
    const roles = ['CLIENT', 'MERCHANT', 'DRIVER', 'ADMIN'] as const;
    const counts = await Promise.all(
      roles.map((role) =>
        this.prisma.user.count({ where: { role } }).then((count) => ({ role, count })),
      ),
    );
    return counts;
  }
}
