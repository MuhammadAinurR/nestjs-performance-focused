export const mockUsers = {
  validUser: {
    email: 'john.doe@example.com',
    full_name: 'John Doe',
    phone_number: '+1234567890',
    password: 'Password123!',
  },

  anotherValidUser: {
    email: 'jane.smith@example.com',
    full_name: 'Jane Smith',
    phone_number: '+0987654321',
    password: 'SecurePass456!',
  },

  invalidUserMissingEmail: {
    full_name: 'Invalid User',
    phone_number: '+1111111111',
    password: 'password123',
  },

  invalidUserWeakPassword: {
    email: 'weak@example.com',
    full_name: 'Weak Password User',
    phone_number: '+2222222222',
    password: '123',
  },

  invalidUserInvalidEmail: {
    email: 'invalid-email',
    full_name: 'Invalid Email User',
    phone_number: '+3333333333',
    password: 'password123',
  },

  invalidUserMissingFields: {
    email: 'missing@example.com',
  },
};

export const mockLoginCredentials = {
  validLogin: {
    email: 'john.doe@example.com',
    password: 'Password123!',
  },

  invalidEmail: {
    email: 'nonexistent@example.com',
    password: 'Password123!',
  },

  invalidPassword: {
    email: 'john.doe@example.com',
    password: 'wrongpassword',
  },

  missingEmail: {
    password: 'Password123!',
  },

  missingPassword: {
    email: 'john.doe@example.com',
  },

  emptyCredentials: {},
};

export const mockTokens = {
  invalidToken: 'invalid.jwt.token',
  expiredToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.invalid',
  malformedToken: 'not.a.valid.jwt',
};

export const responseMessages = {
  success: {
    userRegistered: 'User registered successfully',
    loginSuccessful: 'Login successful',
    tokenRefreshed: 'Token refreshed successfully',
    userDataRetrieved: 'User data retrieved successfully',
    logoutSuccessful: 'Logout successful',
  },

  error: {
    userAlreadyExists: 'User with this email already exists',
    invalidCredentials: 'Invalid email or password',
    userNotFound: 'User not found',
    invalidToken: 'Invalid or expired token',
    refreshTokenNotFound: 'Refresh token not found',
    refreshTokenExpired: 'Refresh token has expired',
    validationFailed: 'Validation failed',
    unauthorized: 'Unauthorized',
  },
};

export const expectedResponseFormat = {
  success: {
    rc: 'SUCCESS',
    message: expect.any(String),
    timestamp: expect.any(String),
    payload: expect.any(Object),
  },

  error: {
    rc: 'ERROR',
    message: expect.any(String),
    timestamp: expect.any(String),
    error: expect.any(Object),
  },

  // For registration response (has both user and tokens)
  registerResponse: {
    rc: 'SUCCESS',
    message: expect.any(String),
    timestamp: expect.any(String),
    payload: {
      data: {
        user: {
          id: expect.any(String),
          email: expect.any(String),
          full_name: expect.any(String),
          phone_number: expect.any(String),
          created_at: expect.any(String),
        },
        tokens: {
          access_token: expect.any(String),
          refresh_token: expect.any(String),
        },
      },
    },
  },

  // For login response (has both user and tokens)
  loginResponse: {
    rc: 'SUCCESS',
    message: expect.any(String),
    timestamp: expect.any(String),
    payload: {
      data: {
        user: {
          id: expect.any(String),
          email: expect.any(String),
          full_name: expect.any(String),
          phone_number: expect.any(String),
          created_at: expect.any(String),
          updated_at: expect.any(String),
        },
        tokens: {
          access_token: expect.any(String),
          refresh_token: expect.any(String),
        },
      },
    },
  },

  // For /auth/me response (only has user data)
  profileResponse: {
    rc: 'SUCCESS',
    message: expect.any(String),
    timestamp: expect.any(String),
    payload: {
      data: {
        user: {
          id: expect.any(String),
          email: expect.any(String),
          full_name: expect.any(String),
          phone_number: expect.any(String),
          created_at: expect.any(String),
          updated_at: expect.any(String),
        },
      },
    },
  },

  userResponse: {
    id: expect.any(String),
    email: expect.any(String),
    full_name: expect.any(String),
    phone_number: expect.any(String),
    created_at: expect.any(String),
  },
};
