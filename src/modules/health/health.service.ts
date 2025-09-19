import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { APP_VERSION } from '../../config/index.js';

@Injectable()
export class HealthService {
  private readonly started = process.uptime();
  constructor(private readonly prisma: PrismaService) {}

  appHealth() {
    return {
      status: 'ok',
      version: APP_VERSION,
      ts: Date.now(),
      uptime: process.uptime(),
      started: this.started,
    };
  }

  async dbHealth() {
    const db = await this.prisma.healthCheck();
    return {
      database: db,
      application: {
        status: 'ok',
        version: APP_VERSION,
        uptime: process.uptime(),
      },
    };
  }
}
