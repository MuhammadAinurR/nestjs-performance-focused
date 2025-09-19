import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import { AppModule } from './app.module.js';
import { APP_PORT } from './config/index.js';

async function bootstrap() {
  const fastify = new FastifyAdapter({
    logger: false, // disable Nest logger, keep ultra light
    trustProxy: true
  });

  const app = await NestFactory.create<NestFastifyApplication>(AppModule, fastify, {
    logger: false,
  });

  // Disable unnecessary features
  app.enableShutdownHooks();

  await app.listen(APP_PORT, '0.0.0.0');
  // Simple startup log (stdout only) for dev debugging; keep minimal.
  console.log(`UP on :${APP_PORT}`);
}

bootstrap();
