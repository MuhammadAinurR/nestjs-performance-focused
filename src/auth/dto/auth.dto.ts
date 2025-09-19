import { IsEmail, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'john.doe@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @MinLength(6)
  password: string;
}

export class RegisterDto {
  @ApiProperty({ example: 'Rofiq Rofiq' })
  @IsString()
  @MinLength(2)
  full_name: string;

  @ApiProperty({ example: '+6285731966274' })
  @IsString()
  @MinLength(10)
  phone_number: string;

  @ApiProperty({ example: 'rofiq@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @MinLength(6)
  password: string;
}

export class RefreshTokenDto {
  @ApiProperty({ example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' })
  @IsString()
  refresh_token: string;
}

export class AuthResponseDto {
  @ApiProperty({ example: 'SUCCESS' })
  rc: string;

  @ApiProperty({ example: 'Authentication successful' })
  message: string;

  @ApiProperty({ example: '2025-09-19T15:30:35.721Z' })
  timestamp: string;

  @ApiProperty({
    example: {
      user: {
        id: 'cuid123',
        email: 'john.doe@example.com',
        fullName: 'John Doe',
        phoneNumber: '+1234567890'
      },
      tokens: {
        access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        refresh_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
      }
    }
  })
  payload: {
    user: {
      id: string;
      email: string;
      fullName: string;
      phoneNumber: string;
    };
    tokens: {
      access_token: string;
      refresh_token: string;
    };
  };
}
