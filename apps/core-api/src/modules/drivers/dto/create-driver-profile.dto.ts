import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class CreateDriverProfileDto {
  @ApiProperty({ example: 'Carlos Pérez' })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiProperty({ example: '1107654321' })
  @IsString()
  @MinLength(8)
  cedula: string;

  @ApiProperty({ example: 'moto', description: 'moto | carro | bicicleta' })
  @IsString()
  vehicleType: string;

  @ApiProperty({ example: 'ZMR-123' })
  @IsString()
  plate: string;
}
