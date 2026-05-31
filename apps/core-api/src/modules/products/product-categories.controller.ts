import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { ProductCategoriesService } from './product-categories.service';
import { CreateProductCategoryDto } from './dto/create-product-category.dto';
import { UpdateProductCategoryDto } from './dto/update-product-category.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('product-categories')
@Controller('stores/:storeId/product-categories')
export class ProductCategoriesController {
  constructor(private readonly productCategoriesService: ProductCategoriesService) {}

  @Get()
  @ApiOperation({ summary: 'List product categories for a store (public)' })
  findAll(@Param('storeId') storeId: string) {
    return this.productCategoriesService.findAll(storeId);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT', 'ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create product category (store owner or ADMIN)' })
  create(
    @Param('storeId') storeId: string,
    @Body() dto: CreateProductCategoryDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.productCategoriesService.create(storeId, dto, user.id, user.role);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT', 'ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update product category (store owner or ADMIN)' })
  update(
    @Param('storeId') storeId: string,
    @Param('id') id: string,
    @Body() dto: UpdateProductCategoryDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.productCategoriesService.update(storeId, id, dto, user.id, user.role);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT', 'ADMIN')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Deactivate product category (store owner or ADMIN)' })
  remove(
    @Param('storeId') storeId: string,
    @Param('id') id: string,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.productCategoriesService.remove(storeId, id, user.id, user.role);
  }
}
