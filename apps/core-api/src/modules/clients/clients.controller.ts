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
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { ClientsService } from './clients.service';
import { CreateClientProfileDto } from './dto/create-client-profile.dto';
import { UpdateClientProfileDto } from './dto/update-client-profile.dto';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateAddressDto } from './dto/update-address.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('clients')
@Controller('clients')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class ClientsController {
  constructor(private readonly clientsService: ClientsService) {}

  // ─── Profile ────────────────────────────────────────────────────────────────

  @Post('profile')
  @Roles('CLIENT')
  @ApiOperation({ summary: 'Create client profile (CLIENT only)' })
  createProfile(
    @CurrentUser() user: { id: string },
    @Body() dto: CreateClientProfileDto,
  ) {
    return this.clientsService.createProfile(user.id, dto);
  }

  @Get('me')
  @Roles('CLIENT')
  @ApiOperation({ summary: 'Get my client profile' })
  getMyProfile(@CurrentUser() user: { id: string }) {
    return this.clientsService.getMyProfile(user.id);
  }

  @Patch('me')
  @Roles('CLIENT')
  @ApiOperation({ summary: 'Update my client profile' })
  updateMyProfile(
    @CurrentUser() user: { id: string },
    @Body() dto: UpdateClientProfileDto,
  ) {
    return this.clientsService.updateMyProfile(user.id, dto);
  }

  // ─── Saved Addresses ────────────────────────────────────────────────────────

  @Get('me/addresses')
  @Roles('CLIENT')
  @ApiOperation({ summary: 'List my saved delivery addresses' })
  getMyAddresses(@CurrentUser() user: { id: string }) {
    return this.clientsService.getMyAddresses(user.id);
  }

  @Post('me/addresses')
  @Roles('CLIENT')
  @ApiOperation({ summary: 'Save a new delivery address' })
  addAddress(
    @CurrentUser() user: { id: string },
    @Body() dto: CreateAddressDto,
  ) {
    return this.clientsService.addAddress(user.id, dto);
  }

  @Patch('me/addresses/:addressId')
  @Roles('CLIENT')
  @ApiOperation({ summary: 'Update a saved address' })
  updateAddress(
    @CurrentUser() user: { id: string },
    @Param('addressId') addressId: string,
    @Body() dto: UpdateAddressDto,
  ) {
    return this.clientsService.updateAddress(user.id, addressId, dto);
  }

  @Patch('me/addresses/:addressId/default')
  @Roles('CLIENT')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Set address as default delivery address' })
  setDefaultAddress(
    @CurrentUser() user: { id: string },
    @Param('addressId') addressId: string,
  ) {
    return this.clientsService.setDefaultAddress(user.id, addressId);
  }

  @Delete('me/addresses/:addressId')
  @Roles('CLIENT')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a saved address' })
  deleteAddress(
    @CurrentUser() user: { id: string },
    @Param('addressId') addressId: string,
  ) {
    return this.clientsService.deleteAddress(user.id, addressId);
  }

  // ─── Admin ──────────────────────────────────────────────────────────────────

  @Get()
  @Roles('ADMIN')
  @ApiOperation({ summary: 'List all clients (ADMIN only)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  findAll(@Query('page') page = '1', @Query('limit') limit = '20') {
    return this.clientsService.findAll(Number(page), Number(limit));
  }

  @Patch(':userId/suspend')
  @Roles('ADMIN')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Suspend client account (ADMIN only)' })
  suspend(@Param('userId') userId: string) {
    return this.clientsService.suspend(userId);
  }
}
