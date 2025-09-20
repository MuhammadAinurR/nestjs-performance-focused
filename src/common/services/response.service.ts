import { Injectable } from '@nestjs/common';
import { SuccessResponse, ErrorResponse } from '../interfaces/response.interface';

@Injectable()
export class ResponseService {
  /**
   * Create a standardized success response
   */
  success<T>(data: T, message: string = 'Request completed successfully'): SuccessResponse<T> {
    return {
      rc: 'SUCCESS',
      message,
      timestamp: new Date().toISOString(),
      payload: {
        data
      }
    };
  }

  /**
   * Create a standardized error response
   */
  error(
    message: string,
    code?: string,
    details?: any
  ): ErrorResponse {
    return {
      rc: 'ERROR',
      message,
      timestamp: new Date().toISOString(),
      payload: {
        error: {
          ...(code && { code }),
          ...(details && { details })
        }
      }
    };
  }

  /**
   * Create auth success responses with specific messaging
   */
  authSuccess<T>(data: T, action: 'register' | 'login' | 'refresh' | 'profile' | 'logout'): SuccessResponse<T> {
    const messages = {
      register: 'User registered successfully',
      login: 'Login successful',
      refresh: 'Token refreshed successfully',
      profile: 'Profile retrieved successfully',
      logout: 'Logout successful'
    };

    return this.success(data, messages[action]);
  }

  /**
   * Create health check responses
   */
  healthSuccess<T>(data: T): SuccessResponse<T> {
    return this.success(data, 'Health check completed successfully');
  }
}
