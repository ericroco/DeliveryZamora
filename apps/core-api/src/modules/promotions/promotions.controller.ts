import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { PromotionsService } from './promotions.service';
import { CreatePromotionDto } from './dto/create-promotion.dto';
import { ValidatePromoDto } from './dto/validate-promo.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('promotions')
@Controller('promotions')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class PromotionsController {
  constructor(private readonly promotionsService: PromotionsService) {}

  @Post()
  @Roles('ADMIN', 'MERCHANT')
  @ApiOperation({ summary: 'Create promo code (ADMIN global | MERCHANT for own store)' })
  create(
    @Body() dto: CreatePromotionDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.promotionsService.create(dto, user.id, user.role);
  }

  @Post('validate')
  @Roles('CLIENT')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Validate a promo code before placing order' })
  validate(@Body() dto: ValidatePromoDto) {
    return this.promotionsService.validate(dto.code, dto.storeId ?? '', dto.orderAmount);
  }

  @Get()
  @Roles('ADMIN', 'MERCHANT')
  @ApiOperation({ summary: 'List promotions (ADMIN = all, MERCHANT = own stores)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  findAll(
    @Query('page') page = '1',
    @Query('limit') limit = '20',
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.promotionsService.findAll(Number(page), Number(limit), user.id, user.role);
  }

  @Delete(':id')
  @Roles('ADMIN', 'MERCHANT')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Deactivate promo code' })
  deactivate(
    @Param('id') id: string,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.promotionsService.deactivate(id, user.id, user.role);
  }
}
