import { Request, Response, NextFunction } from 'express';
import { authenticate, optionalAuth } from '../src/middleware/auth';
import { authService } from '../src/services/authService';

jest.mock('../src/services/authService');

describe('Auth Middleware', () => {
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let nextFunction: NextFunction;

  beforeEach(() => {
    mockRequest = {
      headers: {},
    };
    mockResponse = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    nextFunction = jest.fn();
  });

  describe('authenticate', () => {
    it('should authenticate valid token', async () => {
      mockRequest.headers = {
        authorization: 'Bearer valid-token',
      };

      (authService.verifyToken as jest.Mock).mockReturnValue({
        sub: 'user-123',
        email: 'test@example.com',
      });

      await authenticate(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction
      );

      expect(mockRequest.user).toEqual({
        id: 'user-123',
        email: 'test@example.com',
      });
      expect(nextFunction).toHaveBeenCalled();
    });

    it('should reject missing authorization header', async () => {
      mockRequest.headers = {};

      await authenticate(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction
      );

      expect(mockResponse.status).toHaveBeenCalledWith(401);
      expect(mockResponse.json).toHaveBeenCalledWith({
        success: false,
        error: {
          code: 'AUTH_REQUIRED',
          message: 'Missing or invalid Authorization header',
        },
      });
      expect(nextFunction).not.toHaveBeenCalled();
    });

    it('should reject invalid token format', async () => {
      mockRequest.headers = {
        authorization: 'InvalidFormat token',
      };

      await authenticate(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction
      );

      expect(mockResponse.status).toHaveBeenCalledWith(401);
    });
  });

  describe('optionalAuth', () => {
    it('should attach user if token present', async () => {
      mockRequest.headers = {
        authorization: 'Bearer valid-token',
      };

      (authService.verifyToken as jest.Mock).mockReturnValue({
        sub: 'user-123',
        email: 'test@example.com',
      });

      await optionalAuth(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction
      );

      expect(mockRequest.user).toBeDefined();
      expect(nextFunction).toHaveBeenCalled();
    });

    it('should continue without user if no token', async () => {
      mockRequest.headers = {};

      await optionalAuth(
        mockRequest as Request,
        mockResponse as Response,
        nextFunction
      );

      expect(mockRequest.user).toBeUndefined();
      expect(nextFunction).toHaveBeenCalled();
    });
  });
});
