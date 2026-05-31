import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { AdminOrdersFilterDto } from './dto/admin-orders-filter.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@ApiBearerAuth()
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Operational dashboard snapshot' })
  getDashboard() {
    return this.adminService.getDashboard();
  }

  // ─── Orders ──────────────────────────────────────────────────────────────

  @Get('orders')
  @ApiOperation({ summary: 'List all orders with rich filters' })
  @ApiQuery({ name: 'status', required: false })
  @ApiQuery({ name: 'storeId', required: false })
  @ApiQuery({ name: 'driverId', required: false })
  @ApiQuery({ name: 'from', required: false, example: '2026-05-01' })
  @ApiQuery({ name: 'to', required: false, example: '2026-05-31' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  getOrders(
    @Query() filter: AdminOrdersFilterDto,
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.adminService.getOrders(filter, Number(page), Number(limit));
  }

  @Get('orders/:orderId/history')
  @ApiOperation({ summary: 'Status change history for an order' })
  getOrderHistory(@Param('orderId') orderId: string) {
    return this.adminService.getOrderHistory(orderId);
  }

  @Patch('orders/:orderId/cancel')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Force-cancel any non-terminal order (dispute resolution)' })
  forceCancel(
    @Param('orderId') orderId: string,
    @CurrentUser() user: { id: string },
  ) {
    return this.adminService.forceCancel(orderId, user.id);
  }

  // ─── Commissions ─────────────────────────────────────────────────────────

  @Get('commissions')
  @ApiOperation({ summary: 'Commission report for all merchants in a period' })
  @ApiQuery({ name: 'from', required: false, example: '2026-05-01' })
  @ApiQuery({ name: 'to', required: false, example: '2026-05-31' })
  getCommissions(
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.adminService.getCommissions(from, to);
  }

  @Get('commissions/:merchantId')
  @ApiOperation({ summary: 'Commission detail for a specific merchant' })
  @ApiQuery({ name: 'from', required: false, example: '2026-05-01' })
  @ApiQuery({ name: 'to', required: false, example: '2026-05-31' })
  getMerchantCommission(
    @Param('merchantId') merchantId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.adminService.getMerchantCommission(merchantId, from, to);
  }

  // ─── Merchants ────────────────────────────────────────────────────────────

  @Get('merchants/pending')
  @ApiOperation({ summary: 'Merchants pending verification' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  getPendingMerchants(
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.adminService.getPendingMerchants(Number(page), Number(limit));
  }

  // ─── Stores ───────────────────────────────────────────────────────────────

  @Get('stores')
  @ApiOperation({ summary: 'All stores (active + inactive) with merchant info' })
  @ApiQuery({ name: 'isActive', required: false, example: true })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  getStores(
    @Query('isActive') isActive?: string,
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    const activeFilter = isActive !== undefined
      ? isActive === 'true'
      : undefined;
    return this.adminService.getStores(Number(page), Number(limit), activeFilter);
  }

  @Patch('stores/:storeId/activate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Activate a store' })
  activateStore(@Param('storeId') storeId: string) {
    return this.adminService.toggleStore(storeId, true);
  }

  @Patch('stores/:storeId/deactivate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Deactivate a store' })
  deactivateStore(@Param('storeId') storeId: string) {
    return this.adminService.toggleStore(storeId, false);
  }
}
