import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { HealthService } from './health.service';
import { HealthCheckResponseDto, DatabaseHealthResponseDto } from './dto/health.dto';

@ApiTags('Health')
@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  @ApiOperation({ summary: 'Basic health check' })
  @ApiResponse({
    status: 200,
    description: 'Health check response',
    type: HealthCheckResponseDto,
  })
  async getHealth() {
    return this.healthService.getHealthCheck();
  }

  @Get('db')
  @ApiOperation({ summary: 'Database health check' })
  @ApiResponse({
    status: 200,
    description: 'Database health check response',
    type: DatabaseHealthResponseDto,
  })
  async getDatabaseHealth() {
    return this.healthService.getDatabaseHealth();
  }
}
