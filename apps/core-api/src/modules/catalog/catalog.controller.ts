import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { CatalogService } from './catalog.service';

@ApiTags('catalog')
@Controller('catalog')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Get()
  @ApiOperation({ summary: 'Home screen: categories + featured stores (public)' })
  getHome() {
    return this.catalogService.getHome();
  }

  @Get('search')
  @ApiOperation({ summary: 'Search stores and products by name (public)' })
  @ApiQuery({ name: 'q', required: true, example: 'farmacia' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 10 })
  search(
    @Query('q') q: string,
    @Query('page') page = '1',
    @Query('limit') limit = '10',
  ) {
    return this.catalogService.search(q, Number(page), Number(limit));
  }

  @Get('categories/:categoryId/stores')
  @ApiOperation({ summary: 'Browse stores by category (public)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  getStoresByCategory(
    @Param('categoryId') categoryId: string,
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.catalogService.getStoresByCategory(categoryId, Number(page), Number(limit));
  }
}
