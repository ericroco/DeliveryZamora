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
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { ClientsService } from './clients.service';
import { CreateClientProfileDto } from './dto/create-client-profile.dto';
import { UpdateClientProfileDto } from './dto/update-client-profile.dto';
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
