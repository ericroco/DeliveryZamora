import { Injectable, NotFoundException } from '@nestjs/common';
import { Role } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { ProductCategoriesService } from './product-categories.service';

@Injectable()
export class ProductsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly productCategoriesService: ProductCategoriesService,
  ) {}

  async create(
    storeId: string,
    dto: CreateProductDto,
    requesterId: string,
    requesterRole: Role,
  ) {
    await this.productCategoriesService.assertOwnership(storeId, requesterId, requesterRole);

    if (dto.productCategoryId) {
      const cat = await this.prisma.productCategory.findFirst({
        where: { id: dto.productCategoryId, storeId },
      });
      if (!cat) throw new NotFoundException('Product category not found in this store');
    }

    return this.prisma.product.create({
      data: {
        storeId,
        name: dto.name,
        description: dto.description,
        price: dto.price,
        imageUrl: dto.imageUrl,
        sortOrder: dto.sortOrder ?? 0,
        productCategoryId: dto.productCategoryId,
      },
      include: { productCategory: { select: { id: true, name: true } } },
    });
  }

  async findAll(
    storeId: string,
    page: number,
    limit: number,
    productCategoryId?: string,
    search?: string,
  ) {
    const store = await this.prisma.store.findUnique({ where: { id: storeId } });
    if (!store) throw new NotFoundException('Store not found');

    const skip = (page - 1) * limit;
    const where = {
      storeId,
      isActive: true,
      ...(productCategoryId ? { productCategoryId } : {}),
      ...(search ? { name: { contains: search, mode: 'insensitive' as const } } : {}),
    };

    const [products, total] = await Promise.all([
      this.prisma.product.findMany({
        where,
        skip,
        take: limit,
        include: { productCategory: { select: { id: true, name: true } } },
        orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
      }),
      this.prisma.product.count({ where }),
    ]);

    return { products, total, page, limit };
  }

  async findOne(storeId: string, id: string) {
    const product = await this.prisma.product.findFirst({
      where: { id, storeId, isActive: true },
      include: {
        productCategory: { select: { id: true, name: true } },
        store: { select: { id: true, name: true } },
      },
    });

    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  async update(
    storeId: string,
    id: string,
    dto: UpdateProductDto,
    requesterId: string,
    requesterRole: Role,
  ) {
    await this.productCategoriesService.assertOwnership(storeId, requesterId, requesterRole);
    await this.findOne(storeId, id);

    if (dto.productCategoryId !== undefined && dto.productCategoryId !== null) {
      const cat = await this.prisma.productCategory.findFirst({
        where: { id: dto.productCategoryId, storeId },
      });
      if (!cat) throw new NotFoundException('Product category not found in this store');
    }

    return this.prisma.product.update({
      where: { id },
      data: {
        name: dto.name,
        description: dto.description,
        price: dto.price,
        imageUrl: dto.imageUrl,
        sortOrder: dto.sortOrder,
        isAvailable: dto.isAvailable,
        isActive: dto.isActive,
        ...(dto.productCategoryId !== undefined
          ? { productCategoryId: dto.productCategoryId }
          : {}),
      },
      include: { productCategory: { select: { id: true, name: true } } },
    });
  }

  async remove(
    storeId: string,
    id: string,
    requesterId: string,
    requesterRole: Role,
  ) {
    await this.productCategoriesService.assertOwnership(storeId, requesterId, requesterRole);
    await this.findOne(storeId, id);

    return this.prisma.product.update({
      where: { id },
      data: { isActive: false },
    });
  }
}
