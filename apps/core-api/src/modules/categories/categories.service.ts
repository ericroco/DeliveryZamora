import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';

@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateCategoryDto) {
    const existing = await this.prisma.category.findUnique({
      where: { slug: dto.slug },
    });

    if (existing) {
      throw new ConflictException(`Category with slug "${dto.slug}" already exists`);
    }

    return this.prisma.category.create({
      data: {
        name: dto.name,
        slug: dto.slug,
        iconUrl: dto.iconUrl,
      },
    });
  }

  findAll() {
    return this.prisma.category.findMany({
      where: { isActive: true },
      orderBy: { name: 'asc' },
      select: { id: true, name: true, slug: true, iconUrl: true },
    });
  }

  async update(id: string, dto: UpdateCategoryDto) {
    await this.findOne(id);

    if (dto.slug) {
      const collision = await this.prisma.category.findFirst({
        where: { slug: dto.slug, id: { not: id } },
      });
      if (collision) {
        throw new ConflictException(`Category with slug "${dto.slug}" already exists`);
      }
    }

    return this.prisma.category.update({
      where: { id },
      data: {
        name: dto.name,
        slug: dto.slug,
        iconUrl: dto.iconUrl,
        isActive: dto.isActive,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.category.update({
      where: { id },
      data: { isActive: false },
    });
  }

  private async findOne(id: string) {
    const category = await this.prisma.category.findUnique({ where: { id } });

    if (!category) {
      throw new NotFoundException('Category not found');
    }

    return category;
  }
}
