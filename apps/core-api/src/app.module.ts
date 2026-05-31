import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './common/prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';
import { ClientsModule } from './modules/clients/clients.module';
import { MerchantsModule } from './modules/merchants/merchants.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { StoresModule } from './modules/stores/stores.module';
import { ProductsModule } from './modules/products/products.module';
import { PromotionsModule } from './modules/promotions/promotions.module';
import { OrdersModule } from './modules/orders/orders.module';
import { DriversModule } from './modules/drivers/drivers.module';
import { RatingsModule } from './modules/ratings/ratings.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { DeliveryModule } from './modules/delivery/delivery.module';
import { UsersModule } from './modules/users/users.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { CatalogModule } from './modules/catalog/catalog.module';
import { AdminModule } from './modules/admin/admin.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    ClientsModule,
    MerchantsModule,
    CategoriesModule,
    StoresModule,
    ProductsModule,
    PromotionsModule,
    OrdersModule,
    DriversModule,
    RatingsModule,
    NotificationsModule,
    DeliveryModule,
    UsersModule,
    AnalyticsModule,
    CatalogModule,
    AdminModule,
  ],
})
export class AppModule {}
