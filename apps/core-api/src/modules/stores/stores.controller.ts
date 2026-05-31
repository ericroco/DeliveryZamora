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
import { StoresService } from './stores.service';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('stores')
@Controller('stores')
export class StoresController {
  constructor(private readonly storesService: StoresService) {}

  @Get()
  @ApiOperation({ summary: 'List active stores (public, filterable by category)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  @ApiQuery({ name: 'categoryId', required: false })
  @ApiQuery({ name: 'search', required: false })
  findAll(
    @Query('page') page = '1',
    @Query('limit') limit = '20',
    @Query('categoryId') categoryId?: string,
    @Query('search') search?: string,
  ) {
    return this.storesService.findAll(Number(page), Number(limit), categoryId, search);
  }

  @Get('mine')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'List my stores (MERCHANT only)' })
  findMine(@CurrentUser() user: { id: string }) {
    return this.storesService.findMine(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get store by ID (public)' })
  findOne(@Param('id') id: string) {
    return this.storesService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create store (MERCHANT only)' })
  create(
    @CurrentUser() user: { id: string },
    @Body() dto: CreateStoreDto,
  ) {
    return this.storesService.create(user.id, dto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT', 'ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update store (owner MERCHANT or ADMIN)' })
  update(
    @Param('id') id: string,
    @Body() dto: UpdateStoreDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.storesService.update(id, dto, user.id, user.role);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MERCHANT', 'ADMIN')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Deactivate store (owner MERCHANT or ADMIN)' })
  remove(
    @Param('id') id: string,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.storesService.remove(id, user.id, user.role);
  }
}
