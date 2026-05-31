import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MinLength } from 'class-validator';

export class UpdateDriverProfileDto {
  @ApiPropertyOptional({ example: 'Carlos Pérez' })
  @IsOptional()
  @IsString()
  @MinLength(2)
  name?: string;

  @ApiPropertyOptional({ example: 'moto' })
  @IsOptional()
  @IsString()
  vehicleType?: string;

  @ApiPropertyOptional({ example: 'ZMR-456' })
  @IsOptional()
  @IsString()
  plate?: string;
}
