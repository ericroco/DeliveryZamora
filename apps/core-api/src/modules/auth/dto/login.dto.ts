import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({ example: '+593987654321' })
  @IsString()
  phone: string;

  @ApiProperty()
  @IsString()
  @MinLength(8)
  password: string;
}
