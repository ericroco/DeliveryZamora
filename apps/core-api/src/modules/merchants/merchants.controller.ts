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
import { MerchantsService } from './merchants.service';
import { CreateMerchantProfileDto } from './dto/create-merchant-profile.dto';
import { UpdateMerchantProfileDto } from './dto/update-merchant-profile.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('merchants')
@Controller('merchants')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class MerchantsController {
  constructor(private readonly merchantsService: MerchantsService) {}

  @Post('profile')
  @Roles('MERCHANT')
  @ApiOperation({ summary: 'Create merchant profile (MERCHANT only)' })
  createProfile(
    @CurrentUser() user: { id: string },
    @Body() dto: CreateMerchantProfileDto,
  ) {
    return this.merchantsService.createProfile(user.id, dto);
  }

  @Get('me')
  @Roles('MERCHANT')
  @ApiOperation({ summary: 'Get my merchant profile' })
  getMyProfile(@CurrentUser() user: { id: string }) {
    return this.merchantsService.getMyProfile(user.id);
  }

  @Patch('me')
  @Roles('MERCHANT')
  @ApiOperation({ summary: 'Update my merchant profile' })
  updateMyProfile(
    @CurrentUser() user: { id: string },
    @Body() dto: UpdateMerchantProfileDto,
  ) {
    return this.merchantsService.updateMyProfile(user.id, dto);
  }

  @Get()
  @Roles('ADMIN')
  @ApiOperation({ summary: 'List all merchants (ADMIN only)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  findAll(
    @Query('page') page = '1',
    @Query('limit') limit = '20',
  ) {
    return this.merchantsService.findAll(Number(page), Number(limit));
  }

  @Get(':userId')
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Get merchant by userId (ADMIN only)' })
  findOne(@Param('userId') userId: string) {
    return this.merchantsService.findOne(userId);
  }

  @Patch(':userId/verify')
  @Roles('ADMIN')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify/approve merchant (ADMIN only)' })
  verify(@Param('userId') userId: string) {
    return this.merchantsService.verify(userId);
  }

  @Patch(':userId/suspend')
  @Roles('ADMIN')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Suspend merchant account (ADMIN only)' })
  suspend(@Param('userId') userId: string) {
    return this.merchantsService.suspend(userId);
  }
}
