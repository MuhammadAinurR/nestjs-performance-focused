import { ApiProperty } from '@nestjs/swagger';

export class BaseResponseDto {
  @ApiProperty({ example: 'SUCCESS' })
  rc: string;

  @ApiProperty({ example: 'Health check completed successfully' })
  message: string;

  @ApiProperty({ example: '2025-09-19T15:30:35.721Z' })
  timestamp: string;

  @ApiProperty()
  payload: any;
}

export class HealthCheckResponseDto extends BaseResponseDto {
  @ApiProperty({
    example: {
      data: {
        rc: 'ERROR',
        reason: 'HealthService undefined',
        hint: 'Check ESM import order / reflect-metadata'
      }
    }
  })
  payload: {
    data: {
      rc: string;
      reason?: string;
      hint?: string;
    };
  };
}

export class DatabaseHealthResponseDto extends BaseResponseDto {
  @ApiProperty({
    example: {
      data: {
        database: {
          status: 'healthy',
          connected: true,
          timestamp: '2025-09-19T15:32:25.217Z'
        },
        application: {
          status: 'ok',
          version: '0.1.0',
          uptime: 3.8815779
        }
      }
    }
  })
  payload: {
    data: {
      database: {
        status: string;
        connected: boolean;
        timestamp: string;
      };
      application: {
        status: string;
        version: string;
        uptime: number;
      };
    };
  };
}
