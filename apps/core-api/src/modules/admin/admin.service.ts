import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { AdminOrdersFilterDto } from './dto/admin-orders-filter.dto';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboard() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [
      pendingOrders,
      activeDeliveries,
      todayStats,
      unverifiedMerchants,
      availableDrivers,
      totalStores,
    ] = await Promise.all([
      this.prisma.order.count({ where: { status: OrderStatus.PENDING } }),
      this.prisma.order.count({ where: { status: OrderStatus.PICKED_UP } }),
      this.prisma.order.aggregate({
        where: { createdAt: { gte: today } },
        _count: { id: true },
        _sum: { totalAmount: true },
      }),
      this.prisma.merchantProfile.count({ where: { isVerified: false } }),
      this.prisma.driverProfile.count({ where: { isAvailable: true } }),
      this.prisma.store.count({ where: { isActive: true } }),
    ]);

    return {
      pendingOrders,
      activeDeliveries,
      todayOrders: todayStats._count.id,
      todayRevenue: todayStats._sum.totalAmount ?? 0,
      unverifiedMerchants,
      availableDrivers,
      totalStores,
    };
  }

  async getOrders(filter: AdminOrdersFilterDto, page: number, limit: number) {
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = {};
    if (filter.status) where.status = filter.status;
    if (filter.storeId) where.storeId = filter.storeId;
    if (filter.driverId) where.driverId = filter.driverId;
    if (filter.from || filter.to) {
      where.createdAt = {
        ...(filter.from ? { gte: new Date(filter.from) } : {}),
        ...(filter.to ? { lte: new Date(`${filter.to}T23:59:59Z`) } : {}),
      };
    }

    const [orders, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        skip,
        take: limit,
        include: {
          client: { select: { id: true, phone: true } },
          store: { select: { id: true, name: true } },
          driver: { select: { userId: true, name: true } },
          items: { select: { quantity: true, unitPrice: true, product: { select: { name: true } } } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.order.count({ where }),
    ]);

    return { orders, total, page, limit };
  }

  async getOrderHistory(orderId: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');

    return this.prisma.orderStatusHistory.findMany({
      where: { orderId },
      include: {
        changedBy: { select: { id: true, phone: true, role: true } },
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async forceCancel(orderId: string, adminId: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');

    if (order.status === OrderStatus.DELIVERED || order.status === OrderStatus.CANCELLED) {
      throw new BadRequestException(`Order is already ${order.status} and cannot be cancelled`);
    }

    const [updated] = await this.prisma.$transaction([
      this.prisma.order.update({
        where: { id: orderId },
        data: { status: OrderStatus.CANCELLED },
      }),
      this.prisma.orderStatusHistory.create({
        data: {
          orderId,
          fromStatus: order.status,
          toStatus: OrderStatus.CANCELLED,
          changedById: adminId,
        },
      }),
    ]);

    return updated;
  }

  async getCommissions(from?: string, to?: string) {
    const where: Record<string, unknown> = { status: OrderStatus.DELIVERED };
    if (from || to) {
      where.createdAt = {
        ...(from ? { gte: new Date(from) } : {}),
        ...(to ? { lte: new Date(`${to}T23:59:59Z`) } : {}),
      };
    }

    const merchants = await this.prisma.merchantProfile.findMany({
      where: { isVerified: true },
      select: {
        userId: true,
        businessName: true,
        commissionRate: true,
        stores: {
          select: {
            id: true,
            name: true,
            orders: {
              where: where as never,
              select: { totalAmount: true },
            },
          },
        },
      },
    });

    return merchants.map((m) => {
      const allOrders = m.stores.flatMap((s) => s.orders);
      const totalRevenue = allOrders.reduce((sum, o) => sum + Number(o.totalAmount), 0);
      const commissionAmount = Math.round(totalRevenue * Number(m.commissionRate) * 100) / 100;
      return {
        merchantId: m.userId,
        businessName: m.businessName,
        commissionRate: m.commissionRate,
        totalOrders: allOrders.length,
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        commissionAmount,
      };
    }).filter((m) => m.totalOrders > 0);
  }

  async getMerchantCommission(merchantId: string, from?: string, to?: string) {
    const merchant = await this.prisma.merchantProfile.findUnique({
      where: { userId: merchantId },
    });
    if (!merchant) throw new NotFoundException('Merchant not found');

    const where: Record<string, unknown> = { status: OrderStatus.DELIVERED };
    if (from || to) {
      where.createdAt = {
        ...(from ? { gte: new Date(from) } : {}),
        ...(to ? { lte: new Date(`${to}T23:59:59Z`) } : {}),
      };
    }

    const stores = await this.prisma.store.findMany({
      where: { merchantId },
      select: {
        id: true,
        name: true,
        orders: {
          where: where as never,
          select: {
            id: true,
            totalAmount: true,
            createdAt: true,
            client: { select: { phone: true } },
          },
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    const allOrders = stores.flatMap((s) =>
      s.orders.map((o) => ({ ...o, storeName: s.name })),
    );
    const totalRevenue = allOrders.reduce((sum, o) => sum + Number(o.totalAmount), 0);
    const commissionAmount = Math.round(totalRevenue * Number(merchant.commissionRate) * 100) / 100;

    return {
      merchantId,
      businessName: merchant.businessName,
      commissionRate: merchant.commissionRate,
      totalOrders: allOrders.length,
      totalRevenue: Math.round(totalRevenue * 100) / 100,
      commissionAmount,
      orders: allOrders,
    };
  }

  async getPendingMerchants(page: number, limit: number) {
    const skip = (page - 1) * limit;
    const where = { isVerified: false };

    const [merchants, total] = await Promise.all([
      this.prisma.merchantProfile.findMany({
        where,
        skip,
        take: limit,
        include: {
          user: { select: { id: true, phone: true, email: true, status: true, createdAt: true } },
        },
        orderBy: { createdAt: 'asc' },
      }),
      this.prisma.merchantProfile.count({ where }),
    ]);

    return { merchants, total, page, limit };
  }

  async getStores(page: number, limit: number, isActive?: boolean) {
    const skip = (page - 1) * limit;
    const where = isActive !== undefined ? { isActive } : {};

    const [stores, total] = await Promise.all([
      this.prisma.store.findMany({
        where,
        skip,
        take: limit,
        include: {
          category: { select: { id: true, name: true } },
          merchant: {
            select: {
              userId: true,
              businessName: true,
              isVerified: true,
              commissionRate: true,
            },
          },
          _count: { select: { orders: true, products: true } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.store.count({ where }),
    ]);

    return { stores, total, page, limit };
  }

  async toggleStore(storeId: string, isActive: boolean) {
    const store = await this.prisma.store.findUnique({ where: { id: storeId } });
    if (!store) throw new NotFoundException('Store not found');

    return this.prisma.store.update({
      where: { id: storeId },
      data: { isActive },
      select: { id: true, name: true, isActive: true },
    });
  }
}
