import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { DiscountType } from '@prisma/client';
import {
  IsEnum,
  IsInt,
  IsISO8601,
  IsNumber,
  IsOptional,
  IsPositive,
  IsString,
  IsUUID,
  MinLength,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreatePromotionDto {
  @ApiProperty({ example: 'BIENVENIDO10' })
  @IsString()
  @MinLength(3)
  code: string;

  @ApiProperty({ example: 'Descuento bienvenida' })
  @IsString()
  name: string;

  @ApiProperty({ enum: DiscountType, example: DiscountType.PERCENTAGE })
  @IsEnum(DiscountType)
  discountType: DiscountType;

  @ApiProperty({ example: 10, description: 'Percentage (0-100) or fixed amount in USD' })
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Type(() => Number)
  discountValue: number;

  @ApiPropertyOptional({ example: 5.00 })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Type(() => Number)
  minOrderAmount?: number;

  @ApiPropertyOptional({ example: 100 })
  @IsOptional()
  @IsInt()
  @IsPositive()
  maxUses?: number;

  @ApiPropertyOptional({ example: '2026-12-31T23:59:59.000Z' })
  @IsOptional()
  @IsISO8601()
  expiresAt?: string;

  @ApiPropertyOptional({ example: 'uuid-of-store', description: 'null = global promo' })
  @IsOptional()
  @IsUUID()
  storeId?: string;
}
