import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { AnalyticsService } from './analytics.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

@ApiTags('analytics')
@Controller('analytics')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@ApiBearerAuth()
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('summary')
  @ApiOperation({ summary: 'Global summary stats' })
  getSummary() {
    return this.analyticsService.getSummary();
  }

  @Get('orders/by-status')
  @ApiOperation({ summary: 'Order count by status' })
  getOrdersByStatus() {
    return this.analyticsService.getOrdersByStatus();
  }

  @Get('revenue')
  @ApiOperation({ summary: 'Revenue per day for the last N days' })
  @ApiQuery({ name: 'days', required: false, example: 30 })
  getRevenue(@Query('days') days = '30') {
    return this.analyticsService.getRevenueByPeriod(Number(days));
  }

  @Get('stores/top')
  @ApiOperation({ summary: 'Top stores by order count' })
  @ApiQuery({ name: 'limit', required: false, example: 10 })
  getTopStores(@Query('limit') limit = '10') {
    return this.analyticsService.getTopStores(Number(limit));
  }

  @Get('drivers/top')
  @ApiOperation({ summary: 'Top drivers by rating' })
  @ApiQuery({ name: 'limit', required: false, example: 10 })
  getTopDrivers(@Query('limit') limit = '10') {
    return this.analyticsService.getTopDrivers(Number(limit));
  }

  @Get('users/by-role')
  @ApiOperation({ summary: 'User count by role' })
  getUsersByRole() {
    return this.analyticsService.getUsersByRole();
  }
}
