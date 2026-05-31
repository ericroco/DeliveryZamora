import {
  Body,
  Controller,
  Get,
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
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('orders')
@Controller('orders')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles('CLIENT')
  @ApiOperation({ summary: 'Place an order (CLIENT only)' })
  create(
    @Body() dto: CreateOrderDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.ordersService.create(dto, user);
  }

  @Get()
  @ApiOperation({ summary: 'List orders (CLIENT = own, MERCHANT = store orders, ADMIN = all)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  findAll(
    @CurrentUser() user: { id: string; role: Role },
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.ordersService.findAll(user, Number(page), Number(limit));
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get order by ID' })
  findOne(
    @Param('id') id: string,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.ordersService.findOne(id, user);
  }

  @Patch(':id/status')
  @UseGuards(RolesGuard)
  @Roles('CLIENT', 'MERCHANT', 'DRIVER', 'ADMIN')
  @ApiOperation({ summary: 'Update order status. CLIENT can cancel PENDING orders only.' })
  updateStatus(
    @Param('id') id: string,
    @Body() dto: UpdateOrderStatusDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.ordersService.updateStatus(id, dto, user);
  }
}
