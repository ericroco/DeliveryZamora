import { Injectable, NotFoundException } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';

interface NotificationPayload {
  userId: string;
  orderId?: string;
  title: string;
  body: string;
}

const STATUS_MESSAGES: Record<OrderStatus, { title: string; body: string } | null> = {
  PENDING:    null,
  CONFIRMED:  { title: 'Pedido confirmado', body: 'Tu pedido fue confirmado. Lo están preparando.' },
  PREPARING:  { title: 'En preparación', body: 'Tu pedido está siendo preparado.' },
  READY:      { title: 'Listo para entrega', body: 'Tu pedido está listo. Un repartidor lo recogerá pronto.' },
  PICKED_UP:  { title: 'En camino', body: 'Tu repartidor está en camino con tu pedido.' },
  DELIVERED:  { title: 'Entregado', body: '¡Tu pedido fue entregado! ¿Cómo calificarías al repartidor?' },
  CANCELLED:  { title: 'Pedido cancelado', body: 'Tu pedido fue cancelado.' },
};

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async createMany(payloads: NotificationPayload[]) {
    if (payloads.length === 0) return;
    return this.prisma.notification.createMany({ data: payloads });
  }

  async notifyOrderStatusChange(
    orderId: string,
    newStatus: OrderStatus,
    clientId: string,
    merchantUserId: string,
  ) {
    const payloads: NotificationPayload[] = [];

    const clientMsg = STATUS_MESSAGES[newStatus];
    if (clientMsg) {
      payloads.push({ userId: clientId, orderId, ...clientMsg });
    }

    if (newStatus === OrderStatus.PENDING) {
      payloads.push({
        userId: merchantUserId,
        orderId,
        title: 'Nuevo pedido',
        body: 'Tienes un nuevo pedido esperando confirmación.',
      });
    }

    await this.createMany(payloads);
  }

  async findMyNotifications(userId: string, page: number, limit: number) {
    const skip = (page - 1) * limit;
    const where = { userId };

    const [notifications, total, unreadCount] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.notification.count({ where }),
      this.prisma.notification.count({ where: { userId, isRead: false } }),
    ]);

    return { notifications, total, unreadCount, page, limit };
  }

  async markAsRead(id: string, userId: string) {
    const notif = await this.prisma.notification.findUnique({ where: { id } });
    if (!notif || notif.userId !== userId) throw new NotFoundException('Notification not found');

    return this.prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });
  }

  async markAllAsRead(userId: string) {
    return this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
  }
}
