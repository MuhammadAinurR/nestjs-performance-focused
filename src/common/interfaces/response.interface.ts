export interface StandardResponse<T = any> {
  rc: 'SUCCESS' | 'ERROR';
  message: string;
  timestamp: string;
  payload?: {
    data?: T;
    error?: {
      code?: string;
      details?: any;
    };
  };
}

export interface SuccessResponse<T = any> {
  rc: 'SUCCESS';
  message: string;
  timestamp: string;
  payload: {
    data: T;
  };
}

export interface ErrorResponse {
  rc: 'ERROR';
  message: string;
  timestamp: string;
  payload: {
    error: {
      code?: string;
      details?: any;
    };
  };
}

// Legacy format support for services that return the structure directly
export interface LegacyServiceResponse<T = any> {
  rc: 'SUCCESS';
  message: string;
  timestamp: string;
  payload: T;
}
