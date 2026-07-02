import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
  MinLength,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateAddressDto {
  @ApiProperty({
    example: 'Casa',
    description: 'A short label for the address (e.g. Casa, Trabajo, Mamá)',
  })
  @IsString()
  @MinLength(1)
  label: string;

  @ApiProperty({ example: 'Calle Bolívar 123, frente al parque, Zamora' })
  @IsString()
  @MinLength(5)
  address: string;

  @ApiPropertyOptional({ example: -4.0679, description: 'Latitude (optional)' })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 8 })
  @Min(-90)
  @Max(90)
  @Type(() => Number)
  latitude?: number;

  @ApiPropertyOptional({ example: -78.9468, description: 'Longitude (optional)' })
  @IsOptional()
  @IsNumber({ maxDecimalPlaces: 8 })
  @Min(-180)
  @Max(180)
  @Type(() => Number)
  longitude?: number;

  @ApiPropertyOptional({
    example: false,
    description: 'Set as default delivery address',
  })
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;
}
