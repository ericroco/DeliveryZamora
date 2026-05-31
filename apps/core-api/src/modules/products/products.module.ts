import { Module } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { ProductCategoriesService } from './product-categories.service';
import { ProductCategoriesController } from './product-categories.controller';

@Module({
  controllers: [ProductCategoriesController, ProductsController],
  providers: [ProductCategoriesService, ProductsService],
})
export class ProductsModule {}
