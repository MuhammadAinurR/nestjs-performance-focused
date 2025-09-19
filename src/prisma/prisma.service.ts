import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  constructor() {
    super({
      log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
      errorFormat: 'pretty',
    });
  }

  async onModuleInit() {
    try {
      await this.$connect();
      console.log('✅ Database connected successfully');
    } catch (error) {
      console.error('❌ Database connection failed:', error);
      throw error;
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }

  async healthCheck(): Promise<{ connected: boolean; timestamp: string }> {
    try {
      await this.$queryRaw`SELECT 1`;
      return {
        connected: true,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      return {
        connected: false,
        timestamp: new Date().toISOString(),
      };
    }
  }
}
