import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as request from 'supertest';
import { PrismaService } from '../../src/prisma/prisma.service';

export class TestHelper {
  static app: INestApplication;
  static moduleRef: TestingModule;
  static prisma: PrismaService;

  static async setupTestApp(moduleMetadata: any): Promise<INestApplication> {
    const module: TestingModule = await Test.createTestingModule(moduleMetadata).compile();

    const app = module.createNestApplication();

    // Setup global pipes, filters, etc. similar to main.ts
    await app.init();

    this.app = app;
    this.moduleRef = module;
    this.prisma = module.get<PrismaService>(PrismaService);

    return app;
  }

  static async cleanupTestApp(): Promise<void> {
    if (this.app) {
      await this.app.close();
    }
  }

  static async clearDatabase(): Promise<void> {
    if (this.prisma) {
      // Clear test data in reverse order of dependencies
      await this.prisma.refreshToken.deleteMany();
      await this.prisma.user.deleteMany();
    }
  }

  static getRequest() {
    return request(this.app.getHttpServer());
  }

  static async createTestUser(userData?: Partial<any>) {
    const defaultUser = {
      email: 'test@example.com',
      full_name: 'Test User',
      phone_number: '+1234567890',
      password: 'password123',
      ...userData,
    };

    return await this.getRequest()
      .post('/auth/register')
      .send(defaultUser)
      .expect(201);
  }

  static async loginTestUser(email = 'test@example.com', password = 'password123') {
    return await this.getRequest()
      .post('/auth/login')
      .send({ email, password })
      .expect(200);
  }

  static getAuthHeaders(accessToken: string) {
    return {
      Authorization: `Bearer ${accessToken}`,
    };
  }
}
