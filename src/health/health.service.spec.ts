import { Test, TestingModule } from '@nestjs/testing';
import { HealthService } from './health.service';
import { PrismaService } from '../prisma/prisma.service';
import { ResponseService } from '../common/services/response.service';

describe('HealthService', () => {
  let service: HealthService;
  let prismaService: PrismaService;

  const mockPrismaService = {
    $queryRaw: jest.fn(),
    healthCheck: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        HealthService,
        ResponseService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    service = module.get<HealthService>(HealthService);
    prismaService = module.get<PrismaService>(PrismaService);

    // Reset mocks
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getHealthCheck', () => {
    it('should return health status', async () => {
      const result = await service.getHealthCheck();

      expect(result).toEqual({
        rc: 'SUCCESS',
        message: 'Health check completed successfully',
        timestamp: expect.any(String),
        payload: {
          data: {
            status: 'ok',
            version: expect.any(String),
            ts: expect.any(Number),
            uptime: expect.any(Number),
            started: expect.any(Number),
          },
        },
      });
    });

    it('should include timestamp in ISO format', async () => {
      const result = await service.getHealthCheck();
      const timestamp = new Date(result.timestamp);

      expect(timestamp).toBeInstanceOf(Date);
      expect(timestamp.getTime()).not.toBeNaN();
    });

    it('should include positive uptime', async () => {
      const result = await service.getHealthCheck();

      expect(result.payload.data.uptime).toBeGreaterThanOrEqual(0);
    });
  });

  describe('getDatabaseHealth', () => {
    it('should return database health when connection is successful', async () => {
      mockPrismaService.healthCheck.mockResolvedValue({
        connected: true,
        timestamp: new Date().toISOString(),
      });

      const result = await service.getDatabaseHealth();

      expect(result.rc).toBe('SUCCESS');
      expect(result.message).toBe('Health check completed successfully');
      expect(result.payload.data.database.status).toBe('healthy');
      expect(result.payload.data.database.connected).toBe(true);
      expect(result.payload.data.application.status).toBe('ok');
      expect(mockPrismaService.healthCheck).toHaveBeenCalled();
    });

    it('should return unhealthy status when database connection fails', async () => {
      mockPrismaService.healthCheck.mockResolvedValue({
        connected: false,
        timestamp: new Date().toISOString(),
      });

      const result = await service.getDatabaseHealth();

      expect(result.rc).toBe('SUCCESS');
      expect(result.message).toBe('Health check completed successfully');
      expect(result.payload.data.database.status).toBe('unhealthy');
      expect(result.payload.data.database.connected).toBe(false);
    });

    it('should include application uptime', async () => {
      mockPrismaService.healthCheck.mockResolvedValue({
        connected: true,
        timestamp: new Date().toISOString(),
      });

      const result = await service.getDatabaseHealth();

      expect(result.payload.data.application.uptime).toBeGreaterThanOrEqual(0);
      expect(typeof result.payload.data.application.uptime).toBe('number');
    });
  });
});
