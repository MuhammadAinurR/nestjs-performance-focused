import { Injectable, NestInterceptor, ExecutionContext, CallHandler, Logger } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class PerformanceInterceptor implements NestInterceptor {
  private readonly logger = new Logger(PerformanceInterceptor.name);

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const now = Date.now();
    const request = context.switchToHttp().getRequest();
    const method = request.method;
    const url = request.url;

    return next.handle().pipe(
      tap(() => {
        const duration = Date.now() - now;

        // Log slow requests (>1000ms)
        if (duration > 1000) {
          this.logger.warn(`Slow request detected: ${method} ${url} - ${duration}ms`);
        }

        // Log in development
        if (process.env.NODE_ENV === 'development') {
          this.logger.log(`${method} ${url} - ${duration}ms`);
        }
      }),
    );
  }
}
