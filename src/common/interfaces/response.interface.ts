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