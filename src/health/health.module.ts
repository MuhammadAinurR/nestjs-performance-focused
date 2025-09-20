import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';
import { ResponseService } from '../common/services/response.service';

@Module({
  controllers: [HealthController],
  providers: [HealthService, ResponseService],
})
export class HealthModule { }
