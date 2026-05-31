import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsDateString, IsEnum, IsOptional, IsUUID } from 'class-validator';
import { OrderStatus } from '@prisma/client';

export class AdminOrdersFilterDto {
  @ApiPropertyOptional({ enum: OrderStatus })
  @IsOptional()
  @IsEnum(OrderStatus)
  status?: OrderStatus;

  @ApiPropertyOptional({ example: 'uuid-of-store' })
  @IsOptional()
  @IsUUID()
  storeId?: string;

  @ApiPropertyOptional({ example: 'uuid-of-driver' })
  @IsOptional()
  @IsUUID()
  driverId?: string;

  @ApiPropertyOptional({ example: '2026-05-01' })
  @IsOptional()
  @IsDateString()
  from?: string;

  @ApiPropertyOptional({ example: '2026-05-31' })
  @IsOptional()
  @IsDateString()
  to?: string;
}
