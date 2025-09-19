import { Controller, Get } from '@nestjs/common';
import { APP_VERSION } from '../../config/index.js';

@Controller('health')
export class HealthController {
  private readonly started = process.uptime();
  
  @Get()
  health() {
    return { 
      status: 'ok', 
      version: APP_VERSION, 
      ts: Date.now(), 
      uptime: process.uptime(), 
      started: this.started 
    };
  }
}
