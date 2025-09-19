import { Injectable, ConflictException, UnauthorizedException, BadRequestException, ServiceUnavailableException } from '@nestjs/common';
import { CreateUserDto, LoginDto } from './dto/index.js';
import * as bcrypt from 'bcrypt';
import type { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import { TokenService } from './token.service.js';

@Injectable()
export class AuthService {
  constructor(private readonly prisma: PrismaService, private readonly tokenService: TokenService) {}

  async createUser(createUserDto: CreateUserDto) {
    // Check if database is available
    if (!this.prisma.isDatabaseAvailable) {
      throw new ServiceUnavailableException('Database is currently unavailable. Please try again later.');
    }

    const { fullName, phoneNumber, email, password } = createUserDto;

    // Check if user already exists
    const existingUser = await this.prisma.safeOperation(async () => {
      return await this.prisma.user.findFirst({
        where: {
          OR: [
            { email },
            { phoneNumber }
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
            phoneNumber,
            password: hashedPassword,
          },
        });

        const userDetails = await tx.userDetails.create({
          data: {
            userId: user.id,
            fullName,
          },
        });

        return {
          id: user.id,
          email: user.email,
          phoneNumber: user.phoneNumber,
          fullName: userDetails.fullName,
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

    const { email, phoneNumber, password } = loginDto;

    // Validate that either email or phoneNumber is provided
    if (!email && !phoneNumber) {
      throw new BadRequestException('Either email or phone number must be provided');
    }

    // Find user by email or phoneNumber
    const user = await this.prisma.safeOperation(async () => {
      return await this.prisma.user.findFirst({
        where: email 
          ? { email }
          : { phoneNumber },
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
      phoneNumber: user.phoneNumber,
      fullName: user.userDetails?.fullName,
      createdAt: user.createdAt,
    };

    const token = this.tokenService.signAccessToken({ sub: user.id, email: user.email });

    return { user: baseUser, auth: token };
  }
}