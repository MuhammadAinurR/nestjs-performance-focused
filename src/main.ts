import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module.js';
import { APP_PORT } from './config/index.js';
import { ResponseInterceptor, GlobalExceptionFilter } from './common/index.js';

async function bootstrap() {
  const fastify = new FastifyAdapter({
    logger: false, // disable Nest logger, keep ultra light
    trustProxy: true
  });

  const app = await NestFactory.create<NestFastifyApplication>(AppModule, fastify, {
    logger: false,
  });

  // Global response interceptor for consistent format
  app.useGlobalInterceptors(new ResponseInterceptor());
  
  // Global exception filter for error handling
  app.useGlobalFilters(new GlobalExceptionFilter());
  
  // Global validation pipe for request validation
  app.useGlobalPipes(new ValidationPipe({
    transform: true,
    whitelist: true,
    forbidNonWhitelisted: true,
    disableErrorMessages: process.env.NODE_ENV === 'production',
  }));

  // Disable unnecessary features
  app.enableShutdownHooks();

  await app.listen(APP_PORT, '0.0.0.0');
  // Simple startup log (stdout only) for dev debugging; keep minimal.
  console.log(`UP on :${APP_PORT}`);
}

bootstrap();
