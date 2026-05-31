import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { DeliveryService } from './delivery.service';
import { UpdateLocationDto } from './dto/update-location.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('delivery')
@Controller('delivery')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class DeliveryController {
  constructor(private readonly deliveryService: DeliveryService) {}

  @Patch('orders/:orderId/location')
  @Roles('DRIVER', 'ADMIN')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update driver location for an active order (DRIVER only)' })
  updateLocation(
    @Param('orderId') orderId: string,
    @Body() dto: UpdateLocationDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.deliveryService.updateLocation(orderId, dto, user);
  }

  @Get('orders/:orderId/location')
  @Roles('CLIENT', 'MERCHANT', 'DRIVER', 'ADMIN')
  @ApiOperation({ summary: 'Get current driver location for an order' })
  getLocation(
    @Param('orderId') orderId: string,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.deliveryService.getLocation(orderId, user);
  }
}
