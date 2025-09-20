import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ResponseService } from '../common/services/response.service';

@Injectable()
export class HealthService {
  private readonly startTime = Date.now();
  private readonly appStartTime = process.hrtime();

  constructor(
    private readonly prisma: PrismaService,
    private readonly responseService: ResponseService,
  ) { }

  async getHealthCheck() {
    const timestamp = new Date().toISOString();
    const now = Date.now();
    const uptime = (now - this.startTime) / 1000;
    const started = process.hrtime(this.appStartTime);
    const startedSeconds = started[0] + started[1] / 1e9;

    return this.responseService.healthSuccess({
      status: 'ok',
      version: process.env.APP_VERSION || '0.1.0',
      ts: now,
      uptime,
      started: startedSeconds,
    });
  }

  async getDatabaseHealth() {
    const timestamp = new Date().toISOString();
    const dbHealth = await this.prisma.healthCheck();
    const uptime = (Date.now() - this.startTime) / 1000;

    return this.responseService.healthSuccess({
      database: {
        status: dbHealth.connected ? 'healthy' : 'unhealthy',
        connected: dbHealth.connected,
        timestamp: dbHealth.timestamp,
      },
      application: {
        status: 'ok',
        version: process.env.APP_VERSION || '0.1.0',
        uptime,
      },
    });
  }
}
