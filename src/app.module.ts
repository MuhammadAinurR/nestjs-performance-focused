import { Module } from '@nestjs/common';
import { HealthModule } from './modules/index.js';

@Module({
  imports: [HealthModule]
})
export class AppModule {}
