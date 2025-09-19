import { Injectable, ConflictException, UnauthorizedException, BadRequestException, ServiceUnavailableException } from '@nestjs/common';
import { CreateUserDto, LoginDto } from './dto/index.js';
import * as bcrypt from 'bcrypt';
import type { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import { TokenService } from './token.service.js';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService, private readonly tokenService: TokenService) { }

  async createUser(createUserDto: CreateUserDto) {
    // Check if database is available
    if (!this.prisma.isDatabaseAvailable) {
      throw new ServiceUnavailableException('Database is currently unavailable. Please try again later.');
    }

    const { full_name, phone_number, email, password } = createUserDto;

    // Check if user already exists
    const existingUser = await this.prisma.safeOperation(async () => {
      return await this.prisma.user.findFirst({
        where: {
          OR: [
            { email },
            { phone_number }
          ]
        }
      });
    });

    if (existingUser) {
      throw new ConflictException('User with this email or phone number already exists');
    }

    // Hash password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create user with details in transaction for consistency
    const result = await this.prisma.safeOperation(async () => {
      return await this.prisma!.$transaction(async (tx: Prisma.TransactionClient) => {
        const user = await tx.user.create({
          data: {
            email,
            phone_number,
            password: hashedPassword,
          },
        });

        const userDetails = await tx.userDetails.create({
          data: {
            userId: user.id,
            full_name,
          },
        });

        return {
          id: user.id,
          email: user.email,
          phone_number: user.phone_number,
          full_name: userDetails.full_name,
          createdAt: user.createdAt,
        };
      });
    });

    if (!result) {
      throw new ServiceUnavailableException('Failed to create user due to database connectivity issues');
    }

    const token = this.tokenService.signAccessToken({ sub: result.id, email: result.email });
    return { user: result, auth: token };
  }

  async login(loginDto: LoginDto) {
    // Check if database is available
    if (!this.prisma.isDatabaseAvailable) {
      throw new ServiceUnavailableException('Database is currently unavailable. Please try again later.');
    }

    const { email, phone_number, password } = loginDto;

    // Validate that either email or phone_number is provided
    if (!email && !phone_number) {
      throw new BadRequestException('Either email or phone number must be provided');
    }

    // Find user by email or phone_number
    const user = await this.prisma.safeOperation(async () => {
      return await this.prisma.user.findFirst({
        where: email
          ? { email }
          : { phone_number },
        include: {
          userDetails: true,
        },
      });
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const baseUser = {
      id: user.id,
      email: user.email,
      phone_number: user.phone_number,
      full_name: user.userDetails?.full_name,
      createdAt: user.createdAt,
    };

    const token = this.tokenService.signAccessToken({ sub: user.id, email: user.email });

    return { user: baseUser, auth: token };
  }
}
