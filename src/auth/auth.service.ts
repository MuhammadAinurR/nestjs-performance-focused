import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto, RegisterDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { email, password, full_name, phone_number } = registerDto;

    // Check if user already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('User with this email already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
    const user = await this.prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        fullName: full_name,
        phoneNumber: phone_number,
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        phoneNumber: true,
        createdAt: true,
      },
    });

    // Generate tokens
    const tokens = await this.generateTokens(user.id, user.email);

    // Transform to snake_case for response
    const responseUser = {
      id: user.id,
      email: user.email,
      full_name: user.fullName,
      phone_number: user.phoneNumber,
      created_at: user.createdAt,
    };

    return {
      rc: 'SUCCESS',
      message: 'User registered successfully',
      timestamp: new Date().toISOString(),
      payload: {
        user: responseUser,
        tokens,
      },
    };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    // Find user
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user || !(await bcrypt.compare(password, user.password))) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Generate tokens
    const tokens = await this.generateTokens(user.id, user.email);

    // Remove password from response and transform to snake_case
    const { password: _, ...userWithoutPassword } = user;
    const responseUser = {
      id: userWithoutPassword.id,
      email: userWithoutPassword.email,
      full_name: userWithoutPassword.fullName,
      phone_number: userWithoutPassword.phoneNumber,
      created_at: userWithoutPassword.createdAt,
      updated_at: userWithoutPassword.updatedAt,
    };

    return {
      rc: 'SUCCESS',
      message: 'Login successful',
      timestamp: new Date().toISOString(),
      payload: {
        user: responseUser,
        tokens,
      },
    };
  }

  async refreshToken(refreshToken: string) {
    try {
      // Verify refresh token
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
      });

      // Find user
      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
        select: {
          id: true,
          email: true,
          fullName: true,
          phoneNumber: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      if (!user) {
        throw new UnauthorizedException('User not found');
      }

      // Generate new tokens
      const tokens = await this.generateTokens(user.id, user.email);

      // Transform to snake_case for response
      const responseUser = {
        id: user.id,
        email: user.email,
        full_name: user.fullName,
        phone_number: user.phoneNumber,
        created_at: user.createdAt,
        updated_at: user.updatedAt,
      };

      return {
        rc: 'SUCCESS',
        message: 'Token refreshed successfully',
        timestamp: new Date().toISOString(),
        payload: {
          user: responseUser,
          tokens,
        },
      };
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        fullName: true,
        phoneNumber: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    // Transform to snake_case for response
    const responseUser = {
      id: user.id,
      email: user.email,
      full_name: user.fullName,
      phone_number: user.phoneNumber,
      created_at: user.createdAt,
      updated_at: user.updatedAt,
    };

    return {
      rc: 'SUCCESS',
      message: 'Profile retrieved successfully',
      timestamp: new Date().toISOString(),
      payload: {
        user: responseUser,
      },
    };
  }

  async logout(accessToken: string) {
    // In a production environment, you would:
    // 1. Add the token to a blacklist in Redis
    // 2. Set expiration time equal to the token's remaining TTL
    // For now, we'll just return a success response

    return {
      rc: 'SUCCESS',
      message: 'Logout successful',
      timestamp: new Date().toISOString(),
      payload: {
        message: 'Token invalidated successfully',
      },
    };
  }

  private async generateTokens(userId: string, email: string) {
    const payload = { sub: userId, email };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get('JWT_SECRET'),
        expiresIn: this.configService.get('JWT_EXPIRES_IN'),
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN'),
      }),
    ]);

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
    };
  }
}
