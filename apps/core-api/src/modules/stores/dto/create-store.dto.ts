import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsObject,
  IsNumber,
  MinLength,
  IsUUID,
  Min,
  Max,
} from 'class-validator';

export class CreateStoreDto {
  @ApiProperty({ example: 'Farmacia Central — Sucursal Norte' })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiProperty({ example: 'uuid-of-category' })
  @IsUUID()
  categoryId: string;

  @ApiProperty({ example: 'Av. 24 de Mayo y Diego de Vaca, Zamora' })
  @IsString()
  address: string;

  @ApiPropertyOptional({ example: 'Atendemos urgencias farmacéuticas 24h' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: '+593987654321' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ example: -4.0679 })
  @IsOptional()
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude?: number;

  @ApiPropertyOptional({ example: -78.9468 })
  @IsOptional()
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude?: number;

  @ApiPropertyOptional({
    example: { monday: { open: '08:00', close: '22:00' }, sunday: null },
  })
  @IsOptional()
  @IsObject()
  openingHours?: Record<string, { open: string; close: string } | null>;
}
