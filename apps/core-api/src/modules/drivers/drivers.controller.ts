import {
  Body,
  Controller,
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
import { DriversService } from './drivers.service';
import { CreateDriverProfileDto } from './dto/create-driver-profile.dto';
import { UpdateDriverProfileDto } from './dto/update-driver-profile.dto';
import { RateDriverDto } from './dto/rate-driver.dto';
import { SetAvailabilityDto } from './dto/set-availability.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('drivers')
@Controller('drivers')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class DriversController {
  constructor(private readonly driversService: DriversService) {}

  @Post('profile')
  @Roles('DRIVER')
  @ApiOperation({ summary: 'Create driver profile (DRIVER only)' })
  createProfile(
    @CurrentUser() user: { id: string },
    @Body() dto: CreateDriverProfileDto,
  ) {
    return this.driversService.createProfile(user.id, dto);
  }

  @Get('me')
  @Roles('DRIVER')
  @ApiOperation({ summary: 'Get my driver profile' })
  getMyProfile(@CurrentUser() user: { id: string }) {
    return this.driversService.getMyProfile(user.id);
  }

  @Patch('me')
  @Roles('DRIVER')
  @ApiOperation({ summary: 'Update my driver profile' })
  updateMyProfile(
    @CurrentUser() user: { id: string },
    @Body() dto: UpdateDriverProfileDto,
  ) {
    return this.driversService.updateMyProfile(user.id, dto);
  }

  @Patch('me/availability')
  @Roles('DRIVER')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Toggle availability on/off' })
  setAvailability(
    @CurrentUser() user: { id: string },
    @Body() dto: SetAvailabilityDto,
  ) {
    return this.driversService.setAvailability(user.id, dto.isAvailable);
  }

  @Get('available-orders')
  @Roles('DRIVER')
  @ApiOperation({ summary: 'List READY orders without a driver assigned' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  getAvailableOrders(
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.driversService.getAvailableOrders(Number(page), Number(limit));
  }

  @Post('orders/:orderId/rate')
  @Roles('CLIENT')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Rate driver after delivery (CLIENT only)' })
  rateDriver(
    @Param('orderId') orderId: string,
    @Body() dto: RateDriverDto,
    @CurrentUser() user: { id: string; role: Role },
  ) {
    return this.driversService.rateDriver(orderId, dto, user.id);
  }

  @Get()
  @Roles('ADMIN')
  @ApiOperation({ summary: 'List all drivers (ADMIN only)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  findAll(
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.driversService.findAll(Number(page), Number(limit));
  }

  @Get(':userId')
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Get driver by userId (ADMIN only)' })
  findOne(@Param('userId') userId: string) {
    return this.driversService.findOne(userId);
  }

  @Patch(':userId/suspend')
  @Roles('ADMIN')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Suspend driver account (ADMIN only)' })
  suspend(@Param('userId') userId: string) {
    return this.driversService.suspend(userId);
  }
}
