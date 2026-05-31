import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateLocationDto {
  @ApiProperty({ example: -4.0679, description: 'Latitude' })
  @IsNumber({ maxDecimalPlaces: 8 })
  @Min(-90)
  @Max(90)
  @Type(() => Number)
  lat: number;

  @ApiProperty({ example: -78.9468, description: 'Longitude' })
  @IsNumber({ maxDecimalPlaces: 8 })
  @Min(-180)
  @Max(180)
  @Type(() => Number)
  lng: number;
}
