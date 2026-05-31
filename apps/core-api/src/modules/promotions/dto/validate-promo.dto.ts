import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNumber, IsOptional, IsPositive, IsString, IsUUID, MinLength } from 'class-validator';
import { Type } from 'class-transformer';

export class ValidatePromoDto {
  @ApiProperty({ example: 'BIENVENIDO10' })
  @IsString()
  @MinLength(3)
  code: string;

  @ApiProperty({ example: 15.50 })
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Type(() => Number)
  orderAmount: number;

  @ApiPropertyOptional({ example: 'uuid-of-store' })
  @IsOptional()
  @IsUUID()
  storeId?: string;
}
