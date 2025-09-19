import { Controller, Get } from '@nestjs/common';
import { HealthService } from './health.service.js';

@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  health() {
    return this.healthService.appHealth();
  }

  @Get('db')
  async databaseHealth() {
    return this.healthService.dbHealth();
  }
}
