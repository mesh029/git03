import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/authService';
import { AuthenticationError } from '../utils/errors';

// Extend Express Request to include user
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email: string;
        isAdmin?: boolean;
        isAgent?: boolean;
      };
    }
  }
}

/**
 * Authentication middleware
 * Verifies JWT token and attaches user to request
 */
export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AuthenticationError('Missing or invalid Authorization header');
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Verify token
    const payload = authService.verifyToken(token);

    // Get user details from database (including roles)
    const user = await authService.getUserById(payload.sub);

    // Attach user to request
    req.user = {
      id: user.id,
      email: user.email,
      isAdmin: user.is_admin,
      isAgent: user.is_agent,
    };

    next();
  } catch (error) {
    if (error instanceof AuthenticationError) {
      res.status(401).json({
        success: false,
        error: {
          code: 'AUTH_REQUIRED',
          message: error.message,
        },
      });
      return;
    }

    next(error);
  }
};

/**
 * Optional authentication middleware
 * Attaches user if token is present, but doesn't fail if missing
 */
export const optionalAuth = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const payload = authService.verifyToken(token);
      try {
        const user = await authService.getUserById(payload.sub);
        req.user = {
          id: user.id,
          email: user.email,
      isAdmin: user.is_admin,
      isAgent: user.is_agent,
        };
      } catch (error) {
        // Ignore errors for optional auth
      }
    }

    next();
  } catch (error) {
    // Ignore auth errors for optional auth
    next();
  }
};
