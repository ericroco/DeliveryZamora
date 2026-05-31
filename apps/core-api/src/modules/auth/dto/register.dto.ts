import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  Matches,
  MinLength,
} from 'class-validator';
import { Role } from '@prisma/client';

export class RegisterDto {
  @ApiProperty({ example: '+593987654321' })
  @IsString()
  @Matches(/^\+?[1-9]\d{7,14}$/, { message: 'Invalid phone number' })
  phone: string;

  @ApiPropertyOptional({ example: 'user@example.com' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({ minLength: 8 })
  @IsString()
  @MinLength(8)
  password: string;

  @ApiProperty({ enum: [Role.CLIENT, Role.MERCHANT, Role.DRIVER], example: Role.CLIENT })
  @IsEnum([Role.CLIENT, Role.MERCHANT, Role.DRIVER], {
    message: 'role must be CLIENT, MERCHANT, or DRIVER',
  })
  role: Role;
}
