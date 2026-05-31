import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus, Role } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { PromotionsService } from '../promotions/promotions.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';

type Requester = { id: string; role: Role };

const ALLOWED_TRANSITIONS: Record<OrderStatus, { status: OrderStatus; roles: Role[] }[]> = {
  PENDING: [
    { status: OrderStatus.CONFIRMED, roles: [Role.MERCHANT, Role.ADMIN] },
    { status: OrderStatus.CANCELLED, roles: [Role.MERCHANT, Role.ADMIN, Role.CLIENT] },
  ],
  CONFIRMED: [
    { status: OrderStatus.PREPARING, roles: [Role.MERCHANT, Role.ADMIN] },
    { status: OrderStatus.CANCELLED, roles: [Role.MERCHANT, Role.ADMIN] },
  ],
  PREPARING: [
    { status: OrderStatus.READY, roles: [Role.MERCHANT, Role.ADMIN] },
  ],
  READY: [
    { status: OrderStatus.PICKED_UP, roles: [Role.DRIVER, Role.ADMIN] },
  ],
  PICKED_UP: [
    { status: OrderStatus.DELIVERED, roles: [Role.DRIVER, Role.ADMIN] },
  ],
  DELIVERED: [],
  CANCELLED: [],
};

@Injectable()
export class OrdersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
    private readonly promotions: PromotionsService,
  ) {}

  async create(dto: CreateOrderDto, requester: Requester) {
    if (requester.role !== Role.CLIENT && requester.role !== Role.ADMIN) {
      throw new ForbiddenException('Only clients can place orders');
    }

    const store = await this.prisma.store.findUnique({
      where: { id: dto.storeId, isActive: true },
      include: { merchant: { select: { isVerified: true } } },
    });
    if (!store) throw new NotFoundException('Store not found');
    if (!store.merchant.isVerified) {
      throw new BadRequestException('This store is not yet verified and cannot accept orders');
    }

    const productIds = dto.items.map((i) => i.productId);
    const products = await this.prisma.product.findMany({
      where: { id: { in: productIds }, storeId: dto.storeId, isActive: true },
    });

    if (products.length !== productIds.length) {
      throw new BadRequestException('One or more products not found in this store');
    }

    const unavailable = products.filter((p) => !p.isAvailable);
    if (unavailable.length > 0) {
      throw new BadRequestException(
        `Products out of stock: ${unavailable.map((p) => p.name).join(', ')}`,
      );
    }

    const productMap = new Map(products.map((p) => [p.id, p]));
    const itemsData = dto.items.map((item) => {
      const product = productMap.get(item.productId)!;
      const unitPrice = product.price;
      const subtotal = Number(unitPrice) * item.quantity;
      return { productId: item.productId, quantity: item.quantity, unitPrice, subtotal };
    });

    const originalAmount = itemsData.reduce((sum, i) => sum + i.subtotal, 0);

    // Validate promo before entering transaction (no side effects yet)
    let promoResult: { promotionId: string; discountAmount: number; finalAmount: number } | null = null;
    if (dto.promoCode) {
      promoResult = await this.promotions.validate(dto.promoCode, dto.storeId, originalAmount);
    }

    const discountAmount = promoResult?.discountAmount ?? 0;
    const totalAmount = originalAmount - discountAmount;

    // Create order + consume promo atomically to prevent over-usage race condition
    const order = await this.prisma.$transaction(async (tx) => {
      const created = await tx.order.create({
        data: {
          clientId: requester.id,
          storeId: dto.storeId,
          deliveryAddress: dto.deliveryAddress,
          notes: dto.notes,
          originalAmount,
          discountAmount,
          totalAmount,
          promoCode: dto.promoCode,
          items: { create: itemsData },
        },
        include: {
          items: { include: { product: { select: { id: true, name: true } } } },
          store: { select: { id: true, name: true, merchantId: true } },
        },
      });

      if (promoResult) {
        // Re-check maxUses inside the transaction before incrementing
        const promo = await tx.promotion.findUnique({ where: { id: promoResult.promotionId } });
        if (promo && promo.maxUses !== null && promo.usedCount >= promo.maxUses) {
          throw new BadRequestException('Promo code usage limit reached');
        }
        await tx.promotion.update({
          where: { id: promoResult.promotionId },
          data: { usedCount: { increment: 1 } },
        });
        await tx.promoUsage.create({
          data: {
            promotionId: promoResult.promotionId,
            orderId: created.id,
            userId: requester.id,
            discountApplied: promoResult.discountAmount,
          },
        });
      }

      return created;
    });

    await this.notifications.notifyOrderStatusChange(
      order.id,
      OrderStatus.PENDING,
      requester.id,
      order.store.merchantId,
    );

    return order;
  }

  async findAll(requester: Requester, page: number, limit: number) {
    const skip = (page - 1) * limit;
    let where = {};

    if (requester.role === Role.CLIENT) {
      where = { clientId: requester.id };
    } else if (requester.role === Role.MERCHANT) {
      const merchant = await this.prisma.merchantProfile.findUnique({
        where: { userId: requester.id },
        include: { stores: { select: { id: true } } },
      });
      if (!merchant) throw new NotFoundException('Merchant profile not found');
      where = { storeId: { in: merchant.stores.map((s) => s.id) } };
    } else if (requester.role === Role.DRIVER) {
      where = { driverId: requester.id };
    }
    // ADMIN: no filter → all orders

    const [orders, total] = await Promise.all([
      this.prisma.order.findMany({
        where,
        skip,
        take: limit,
        include: {
          store: { select: { id: true, name: true } },
          items: { include: { product: { select: { id: true, name: true } } } },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.order.count({ where }),
    ]);

    return { orders, total, page, limit };
  }

  async findOne(id: string, requester: Requester) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: {
        store: { select: { id: true, name: true, merchantId: true } },
        items: { include: { product: { select: { id: true, name: true } } } },
        client: { select: { id: true } },
        driver: { select: { userId: true, name: true } },
      },
    });
    if (!order) throw new NotFoundException('Order not found');

    this.assertAccess(order, requester);
    return order;
  }

  async updateStatus(id: string, dto: UpdateOrderStatusDto, requester: Requester) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: { store: { select: { merchantId: true } } },
    });
    if (!order) throw new NotFoundException('Order not found');

    this.assertAccess(order, requester);

    const allowed = ALLOWED_TRANSITIONS[order.status];
    const transition = allowed.find((t) => t.status === dto.status);

    if (!transition) {
      throw new BadRequestException(
        `Cannot transition from ${order.status} to ${dto.status}`,
      );
    }
    if (!transition.roles.includes(requester.role)) {
      throw new ForbiddenException(
        `Role ${requester.role} cannot set status ${dto.status}`,
      );
    }

    const updateData: Record<string, unknown> = { status: dto.status };
    if (dto.status === OrderStatus.PICKED_UP && requester.role === Role.DRIVER) {
      updateData.driverId = requester.id;
    }

    const [updated] = await this.prisma.$transaction([
      this.prisma.order.update({
        where: { id },
        data: updateData,
        include: {
          store: { select: { id: true, name: true, merchantId: true } },
          items: { include: { product: { select: { id: true, name: true } } } },
        },
      }),
      this.prisma.orderStatusHistory.create({
        data: {
          orderId: id,
          fromStatus: order.status,
          toStatus: dto.status,
          changedById: requester.id,
        },
      }),
    ]);

    await this.notifications.notifyOrderStatusChange(
      updated.id,
      dto.status,
      order.clientId,
      updated.store.merchantId,
    );

    return updated;
  }

  private assertAccess(
    order: { clientId: string; store: { merchantId: string }; driverId: string | null },
    requester: Requester,
  ) {
    if (requester.role === Role.ADMIN) return;
    if (requester.role === Role.CLIENT && order.clientId === requester.id) return;
    if (requester.role === Role.MERCHANT && order.store.merchantId === requester.id) return;
    if (requester.role === Role.DRIVER && order.driverId === requester.id) return;
    throw new ForbiddenException('Access denied');
  }
}
