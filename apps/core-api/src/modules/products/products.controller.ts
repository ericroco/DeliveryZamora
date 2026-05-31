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
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('products')
@Controller('stores/:storeId/products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  @ApiOperation({ summary: 'List products for a store (public)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  @ApiQuery({ name: 'productCategoryId', required: false })
  @ApiQuery({ name: 'search', required: false })
  findAll(
    @Param('storeId') storeId: string,
    @Query('page') page = '1',
    @Query('limit') limit = '20',
    @Query('productCategoryId') productCategoryId?: string,
    @Query('search') search?: string,
  ) {
    return this.productsService.findAll(storeId, Number(page), Number(limit), productCategoryId, search);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get product by ID (public)' })
  findOne(@Param('storeId') storeId: string, @Param('id') id: string) {
    return this.productsService.findOne(storeId, id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT', 'ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create product (store owner or ADMIN)' })
  create(
    @Param('storeId') storeId: string,
    @Body() dto: CreateProductDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.productsService.create(storeId, dto, user.id, user.role);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT', 'ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update product (store owner or ADMIN)' })
  update(
    @Param('storeId') storeId: string,
    @Param('id') id: string,
    @Body() dto: UpdateProductDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.productsService.update(storeId, id, dto, user.id, user.role);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT', 'ADMIN')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Deactivate product (store owner or ADMIN)' })
  remove(
    @Param('storeId') storeId: string,
    @Param('id') id: string,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.productsService.remove(storeId, id, user.id, user.role);
  }
}
