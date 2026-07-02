import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, IsPositive, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class AnalyticsPeriodDto {
  @ApiPropertyOptional({
    example: 30,
    default: 30,
    description: 'Number of days to look back (1–365)',
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(365)
  @Type(() => Number)
  days?: number = 30;
}

export class AnalyticsLimitDto {
  @ApiPropertyOptional({
    example: 10,
    default: 10,
    description: 'Max number of results to return (1–50)',
  })
  @IsOptional()
  @IsInt()
  @IsPositive()
  @Max(50)
  @Type(() => Number)
  limit?: number = 10;
}
