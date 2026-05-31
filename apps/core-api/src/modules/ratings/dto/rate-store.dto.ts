import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class RateStoreDto {
  @ApiProperty({ example: 5, description: '1–5 stars' })
  @IsInt()
  @Min(1)
  @Max(5)
  rating: number;

  @ApiPropertyOptional({ example: 'Excelente atención y productos frescos' })
  @IsOptional()
  @IsString()
  comment?: string;
}
