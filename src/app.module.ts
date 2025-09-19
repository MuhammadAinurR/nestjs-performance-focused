import { Module } from '@nestjs/common';
import { HealthModule } from './modules/index.js';
import { PrismaModule } from './modules/prisma/index.js';
import { AuthModule } from './modules/auth/index.js';

@Module({
  imports: [PrismaModule, HealthModule, AuthModule]
})
export class AppModule {}
