import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, MinLength, Matches } from 'class-validator';

export class CreateCategoryDto {
  @ApiProperty({ example: 'Farmacia' })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiProperty({ example: 'farmacia', description: 'URL-safe identifier' })
  @IsString()
  @Matches(/^[a-z0-9-]+$/, { message: 'slug must be lowercase letters, numbers, and hyphens' })
  slug: string;

  @ApiPropertyOptional({ example: 'https://cdn.example.com/icons/farmacia.svg' })
  @IsOptional()
  @IsString()
  iconUrl?: string;
}
