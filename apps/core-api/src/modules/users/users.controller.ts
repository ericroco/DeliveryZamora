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
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { Role, UserStatus } from '@prisma/client';
import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';

class SetStatusDto {
  @ApiProperty({ enum: UserStatus })
  @IsEnum(UserStatus)
  status: UserStatus;
}

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({ summary: 'List all users (ADMIN only)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 20 })
  @ApiQuery({ name: 'role', required: false, enum: Role })
  findAll(
    @Query('page') page = '1',
    @Query('limit') limit = '20',
    @Query('role') role?: Role,
  ) {
    return this.usersService.findAll(Number(page), Number(limit), role);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID (ADMIN only)' })
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Patch(':id/status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Set user status (ADMIN only)' })
  setStatus(@Param('id') id: string, @Body() dto: SetStatusDto) {
    return this.usersService.setStatus(id, dto.status);
  }
}
