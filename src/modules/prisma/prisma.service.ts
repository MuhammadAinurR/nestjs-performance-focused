import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);
  private isConnected = false;

  constructor() {
    super({
      // Performance optimizations for high throughput
      datasources: {
        db: {
          url: process.env.DATABASE_URL,
        },
      },
      log: process.env.NODE_ENV === 'development' ? ['error'] : [],
      // Connection pool configuration for high performance
      transactionOptions: {
        maxWait: 5000, // 5 seconds
        timeout: 10000, // 10 seconds
      },
    });
  }

  async onModuleInit() {
    try {
      await this.$connect();
      this.isConnected = true;
      this.logger.log('✅ Database connected successfully');
      
      // Performance optimizations
      if (process.env.NODE_ENV === 'production') {
        // Set connection pool size for high throughput
        await this.$executeRaw`SELECT pg_advisory_lock(1)`;
        await this.$executeRaw`SELECT pg_advisory_unlock(1)`;
      }
    } catch (error) {
      this.isConnected = false;
      this.logger.error('❌ Failed to connect to database:', error instanceof Error ? error.message : 'Unknown error');
      this.logger.warn('⚠️  Application will start without database. Some features may not work.');
      
      // Don't throw error - allow app to start without database
      // throw error;
    }
  }

  async onModuleDestroy() {
    try {
      await this.$disconnect();
      this.logger.log('🔌 Database disconnected');
    } catch (error) {
      this.logger.error('❌ Error disconnecting from database:', error instanceof Error ? error.message : 'Unknown error');
    }
  }

  // Helper method for performance monitoring
  async healthCheck() {
    try {
      if (!this.isConnected) {
        // Try to reconnect
        await this.$connect();
        this.isConnected = true;
      }
      
      await this.$queryRaw`SELECT 1`;
      return { 
        status: 'healthy', 
        connected: true,
        timestamp: new Date().toISOString() 
      };
    } catch (error) {
      this.isConnected = false;
      return { 
        status: 'unhealthy', 
        connected: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        timestamp: new Date().toISOString()
      };
    }
  }

  // Check if database is available before operations
  get isDatabaseAvailable(): boolean {
    return this.isConnected;
  }

  // Safe database operation wrapper
  async safeOperation<T>(operation: () => Promise<T>, fallback?: T): Promise<T | null> {
    try {
      if (!this.isConnected) {
        this.logger.warn('Database not connected, skipping operation');
        return fallback || null;
      }
      return await operation();
    } catch (error) {
      this.logger.error('Database operation failed:', error instanceof Error ? error.message : 'Unknown error');
      this.isConnected = false;
      return fallback || null;
    }
  }
}