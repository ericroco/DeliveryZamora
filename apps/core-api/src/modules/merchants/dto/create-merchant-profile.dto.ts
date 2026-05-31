import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsObject, MinLength } from 'class-validator';

export class CreateMerchantProfileDto {
  @ApiProperty({ example: 'Farmacia Central' })
  @IsString()
  @MinLength(2)
  businessName: string;

  @ApiPropertyOptional({ example: 'Farmacia con más de 20 años en Zamora' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: 'Av. 24 de Mayo y Diego de Vaca, Zamora' })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiPropertyOptional({ example: '+593987654321' })
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiPropertyOptional({ example: '0990123456001' })
  @IsOptional()
  @IsString()
  ruc?: string;

  @ApiPropertyOptional({
    example: { monday: { open: '08:00', close: '22:00' } },
  })
  @IsOptional()
  @IsObject()
  openingHours?: Record<string, { open: string; close: string }>;
}
