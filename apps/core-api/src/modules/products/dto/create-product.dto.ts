import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsInt,
  IsUUID,
  IsPositive,
  Min,
  MinLength,
  IsNumber,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateProductDto {
  @ApiProperty({ example: 'Paracetamol 500mg x 10' })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiProperty({ example: 1.25, description: 'Price in USD' })
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Type(() => Number)
  price: number;

  @ApiPropertyOptional({ example: 'uuid-of-product-category' })
  @IsOptional()
  @IsUUID()
  productCategoryId?: string;

  @ApiPropertyOptional({ example: 'Caja de 10 tabletas de 500mg' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: 'https://cdn.example.com/products/paracetamol.jpg' })
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiPropertyOptional({ example: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  sortOrder?: number;
}
