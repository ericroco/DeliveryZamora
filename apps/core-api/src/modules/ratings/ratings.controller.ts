import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { RatingsService } from './ratings.service';
import { RateStoreDto } from './dto/rate-store.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('ratings')
@Controller('ratings')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class RatingsController {
  constructor(private readonly ratingsService: RatingsService) {}

  @Post('orders/:orderId/store')
  @Roles('CLIENT')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Rate store after delivery (CLIENT only, once per order)' })
  rateStore(
    @Param('orderId') orderId: string,
    @Body() dto: RateStoreDto,
    @CurrentUser() user: { id: string },
  ) {
    return this.ratingsService.rateStore(orderId, dto, user.id);
  }

  @Get('stores/:storeId')
  @ApiOperation({ summary: 'Get store ratings (public)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  getStoreRatings(
    @Param('storeId') storeId: string,
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.ratingsService.getStoreRatings(storeId, Number(page), Number(limit));
  }
}
