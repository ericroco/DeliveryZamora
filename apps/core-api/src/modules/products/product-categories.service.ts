import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateProductCategoryDto } from './dto/create-product-category.dto';
import { UpdateProductCategoryDto } from './dto/update-product-category.dto';

@Injectable()
export class ProductCategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(
    storeId: string,
    dto: CreateProductCategoryDto,
    requesterId: string,
    requesterRole: Role,
  ) {
    await this.assertOwnership(storeId, requesterId, requesterRole);

    return this.prisma.productCategory.create({
      data: {
        storeId,
        name: dto.name,
        sortOrder: dto.sortOrder ?? 0,
      },
    });
  }

  findAll(storeId: string) {
    return this.prisma.productCategory.findMany({
      where: { storeId, isActive: true },
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
      select: { id: true, name: true, sortOrder: true },
    });
  }

  async update(
    storeId: string,
    id: string,
    dto: UpdateProductCategoryDto,
    requesterId: string,
    requesterRole: Role,
  ) {
    await this.assertOwnership(storeId, requesterId, requesterRole);
    await this.findOne(id, storeId);

    return this.prisma.productCategory.update({
      where: { id },
      data: {
        name: dto.name,
        sortOrder: dto.sortOrder,
        isActive: dto.isActive,
      },
    });
  }

  async remove(
    storeId: string,
    id: string,
    requesterId: string,
    requesterRole: Role,
  ) {
    await this.assertOwnership(storeId, requesterId, requesterRole);
    await this.findOne(id, storeId);

    return this.prisma.productCategory.update({
      where: { id },
      data: { isActive: false },
    });
  }

  private async findOne(id: string, storeId: string) {
    const cat = await this.prisma.productCategory.findFirst({
      where: { id, storeId },
    });

    if (!cat) throw new NotFoundException('Product category not found');
    return cat;
  }

  async assertOwnership(storeId: string, merchantId: string, role: Role) {
    const store = await this.prisma.store.findUnique({ where: { id: storeId } });

    if (!store) throw new NotFoundException('Store not found');

    if (role !== 'ADMIN' && store.merchantId !== merchantId) {
      throw new ForbiddenException('You do not own this store');
    }

    return store;
  }
}
