import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class RateDriverDto {
  @ApiProperty({ example: 5, description: '1–5 stars' })
  @IsInt()
  @Min(1)
  @Max(5)
  rating: number;

  @ApiPropertyOptional({ example: 'Muy puntual' })
  @IsOptional()
  @IsString()
  comment?: string;
}
