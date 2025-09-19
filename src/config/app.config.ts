export const config = {
  app: {
    name: 'ultra-nest-api',
    version: '0.1.0',
    port: process.env.PORT ? parseInt(process.env.PORT, 10) : 3000,
  },
  environment: process.env.NODE_ENV || 'development',
} as const;

// Export individual constants for backward compatibility
export const APP_VERSION = config.app.version;
export const APP_NAME = config.app.name;
export const APP_PORT = config.app.port;