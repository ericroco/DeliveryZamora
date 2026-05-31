import { Module } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrdersController } from './orders.controller';
import { NotificationsModule } from '../notifications/notifications.module';
import { PromotionsModule } from '../promotions/promotions.module';

@Module({
  imports: [NotificationsModule, PromotionsModule],
  controllers: [OrdersController],
  providers: [OrdersService],
})
export class OrdersModule {}
