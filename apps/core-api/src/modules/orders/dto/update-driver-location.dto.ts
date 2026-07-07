import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, Max, Min } from 'class-validator';

export class UpdateDriverLocationDto {
  @ApiProperty({ example: -4.0679, description: 'Latitude of the driver' })
  @IsNumber()
  @Min(-90)
  @Max(90)
  lat: number;

  @ApiProperty({ example: -78.9498, description: 'Longitude of the driver' })
  @IsNumber()
  @Min(-180)
  @Max(180)
  lng: number;
}
