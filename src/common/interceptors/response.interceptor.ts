import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { StandardResponse, SuccessResponse } from '../interfaces/response.interface';

@Injectable()
export class ResponseInterceptor<T> implements NestInterceptor<T, StandardResponse<T>> {
  intercept(context: ExecutionContext, next: CallHandler): Observable<StandardResponse<T>> {
    return next.handle().pipe(
      map((data) => {
        // If data is already in standard format, return as is
        if (data && typeof data === 'object' && 'rc' in data && 'timestamp' in data) {
          return data;
        }

        // Transform data into standard format
        return {
          rc: 'SUCCESS' as const,
          message: this.getSuccessMessage(context),
          timestamp: new Date().toISOString(),
          payload: {
            data: data
          }
        } as SuccessResponse<T>;
      })
    );
  }

  private getSuccessMessage(context: ExecutionContext): string {
    const request = context.switchToHttp().getRequest();
    const method = request.method;
    const path = request.route?.path || request.url;

    // Generate appropriate success messages based on endpoint
    if (path.includes('/health')) {
      return 'Health check completed successfully';
    }

    if (path.includes('/auth/register')) {
      return 'User registration completed successfully';
    }

    if (path.includes('/auth/login')) {
      return 'User authentication completed successfully';
    }

    if (path.includes('/auth/refresh')) {
      return 'Token refresh completed successfully';
    }

    if (path.includes('/auth/me')) {
      return 'Profile retrieval completed successfully';
    }

    if (path.includes('/auth/logout')) {
      return 'Logout completed successfully';
    }

    // Default messages based on HTTP method
    switch (method) {
      case 'POST':
        return 'Resource created successfully';
      case 'PUT':
      case 'PATCH':
        return 'Resource updated successfully';
      case 'DELETE':
        return 'Resource deleted successfully';
      case 'GET':
      default:
        return 'Request completed successfully';
    }
  }
}
