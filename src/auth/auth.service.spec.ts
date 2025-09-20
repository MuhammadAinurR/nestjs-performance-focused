import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { ResponseService } from '../common/services/response.service';
import * as bcrypt from 'bcryptjs';

describe('AuthService', () => {
  let service: AuthService;
  let prismaService: PrismaService;
  let jwtService: JwtService;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    refreshToken: {
      create: jest.fn(),
      findUnique: jest.fn(),
      delete: jest.fn(),
    },
  };

  const mockJwtService = {
    signAsync: jest.fn(),
    verify: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        ResponseService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prismaService = module.get<PrismaService>(PrismaService);
    jwtService = module.get<JwtService>(JwtService);

    // Reset mocks
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('register', () => {
    const registerDto = {
      email: 'test@example.com',
      password: 'password123',
      full_name: 'Test User',
      phone_number: '+1234567890',
    };

    it('should successfully register a new user', async () => {
      const hashedPassword = await bcrypt.hash('password123', 12);
      const createdUser = {
        id: '1',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+1234567890',
        createdAt: new Date(),
      };

      mockPrismaService.user.findUnique.mockResolvedValue(null);
      mockPrismaService.user.create.mockResolvedValue(createdUser);
      mockJwtService.signAsync
        .mockResolvedValueOnce('access_token')
        .mockResolvedValueOnce('refresh_token');
      mockConfigService.get
        .mockReturnValueOnce('access_secret')
        .mockReturnValueOnce('900')
        .mockReturnValueOnce('refresh_secret')
        .mockReturnValueOnce('604800');
      mockPrismaService.refreshToken.create.mockResolvedValue({
        id: 'token_id',
        token: 'refresh_token',
        userId: '1',
        expiresAt: new Date(),
        createdAt: new Date(),
      });

      const result = await service.register(registerDto);

      expect(result.payload.data.user).toEqual({
        id: createdUser.id,
        email: createdUser.email,
        full_name: createdUser.fullName,
        phone_number: createdUser.phoneNumber,
        created_at: createdUser.createdAt,
      });
      expect(result.payload.data.tokens).toEqual({
        access_token: 'access_token',
        refresh_token: 'refresh_token',
      });
      expect(mockPrismaService.user.findUnique).toHaveBeenCalledWith({
        where: { email: registerDto.email },
      });
      expect(mockPrismaService.user.create).toHaveBeenCalled();
    });

    it('should throw ConflictException when user already exists', async () => {
      const existingUser = {
        id: '1',
        email: 'test@example.com',
        fullName: 'Existing User',
        phoneNumber: '+1234567890',
      };

      mockPrismaService.user.findUnique.mockResolvedValue(existingUser);

      await expect(service.register(registerDto)).rejects.toThrow(ConflictException);
      expect(mockPrismaService.user.create).not.toHaveBeenCalled();
    });
  });

  describe('login', () => {
    const loginDto = {
      email: 'test@example.com',
      password: 'password123',
    };

    it('should successfully login with valid credentials', async () => {
      const hashedPassword = await bcrypt.hash('password123', 12);
      const user = {
        id: '1',
        email: 'test@example.com',
        password: hashedPassword,
        fullName: 'Test User',
        phoneNumber: '+1234567890',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.user.findUnique.mockResolvedValue(user);
      mockJwtService.signAsync
        .mockResolvedValueOnce('access_token')
        .mockResolvedValueOnce('refresh_token');
      mockConfigService.get
        .mockReturnValueOnce('access_secret')
        .mockReturnValueOnce('900')
        .mockReturnValueOnce('refresh_secret')
        .mockReturnValueOnce('604800');
      mockPrismaService.refreshToken.create.mockResolvedValue({
        id: 'token_id',
        token: 'refresh_token',
        userId: '1',
        expiresAt: new Date(),
        createdAt: new Date(),
      });

      const result = await service.login(loginDto);

      expect(result.payload.data.tokens).toEqual({
        access_token: 'access_token',
        refresh_token: 'refresh_token',
      });
      expect(result.payload.data.user.email).toBe(loginDto.email);
    });

    it('should throw UnauthorizedException with invalid credentials', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(service.login(loginDto)).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException with wrong password', async () => {
      const hashedPassword = await bcrypt.hash('differentpassword', 12);
      const user = {
        id: '1',
        email: 'test@example.com',
        password: hashedPassword,
        fullName: 'Test User',
        phoneNumber: '+1234567890',
      };

      mockPrismaService.user.findUnique.mockResolvedValue(user);

      await expect(service.login(loginDto)).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('getProfile', () => {
    it('should return user profile', async () => {
      const user = {
        id: '1',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+1234567890',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockPrismaService.user.findUnique.mockResolvedValue(user);

      const result = await service.getProfile('1');

      expect(result.payload.data.user).toEqual({
        id: user.id,
        email: user.email,
        full_name: user.fullName,
        phone_number: user.phoneNumber,
        created_at: user.createdAt,
        updated_at: user.updatedAt,
      });
      expect(mockPrismaService.user.findUnique).toHaveBeenCalledWith({
        where: { id: '1' },
        select: {
          id: true,
          email: true,
          fullName: true,
          phoneNumber: true,
          createdAt: true,
          updatedAt: true,
        },
      });
    });

    it('should throw UnauthorizedException when user not found', async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(service.getProfile('nonexistent')).rejects.toThrow(UnauthorizedException);
    });
  });
});
