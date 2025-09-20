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

export class LogoutDto {
  @ApiProperty({ example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' })
  @IsString()
  access_token: string;
}

export class ProfileResponseDto {
  @ApiProperty({ example: 'SUCCESS' })
  rc: string;

  @ApiProperty({ example: 'Profile retrieved successfully' })
  message: string;

  @ApiProperty({ example: '2025-09-19T15:30:35.721Z' })
  timestamp: string;

  @ApiProperty({
    example: {
      user: {
        id: 'cuid123',
        email: 'john.doe@example.com',
        full_name: 'John Doe',
        phone_number: '+1234567890',
        created_at: '2025-09-19T15:30:35.721Z',
        updated_at: '2025-09-19T15:30:35.721Z',
      },
    },
  })
  payload: {
    user: {
      id: string;
      email: string;
      full_name: string;
      phone_number: string;
      created_at: string;
      updated_at: string;
    };
  };
}

export class LogoutResponseDto {
  @ApiProperty({ example: 'SUCCESS' })
  rc: string;

  @ApiProperty({ example: 'Logout successful' })
  message: string;

  @ApiProperty({ example: '2025-09-19T15:30:35.721Z' })
  timestamp: string;

  @ApiProperty({
    example: {
      message: 'Token invalidated successfully',
    },
  })
  payload: {
    message: string;
  };
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
        full_name: 'John Doe',
        phone_number: '+1234567890',
        created_at: '2025-09-19T15:30:35.721Z',
        updated_at: '2025-09-19T15:30:35.721Z',
      },
      tokens: {
        access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        refresh_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      },
    },
  })
  payload: {
    user: {
      id: string;
      email: string;
      full_name: string;
      phone_number: string;
      created_at: string;
      updated_at: string;
    };
    tokens: {
      access_token: string;
      refresh_token: string;
    };
  };
}
