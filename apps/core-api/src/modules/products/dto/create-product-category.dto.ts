import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, Min, MinLength } from 'class-validator';

export class CreateProductCategoryDto {
  @ApiProperty({ example: 'Analgésicos' })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;
}
