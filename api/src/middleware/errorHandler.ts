import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/errors';
import { logError } from '../utils/logger';

export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  _next: NextFunction
) => {
  if (err instanceof AppError) {
    // Log application errors (warnings for client errors, errors for server errors)
    if (err.statusCode >= 500) {
      logError(err, {
        url: req.originalUrl,
        method: req.method,
        userId: req.user?.id,
        ip: req.ip,
      });
    } else {
      // Client errors are logged as warnings
      logError(err, {
        url: req.originalUrl,
        method: req.method,
        userId: req.user?.id,
        ip: req.ip,
        level: 'warn',
      });
    }

    return res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message,
        ...(err.details && { details: err.details }),
      },
    });
  }

  // Log unexpected errors with full context
  logError(err, {
    url: req.originalUrl,
    method: req.method,
    userId: req.user?.id,
    ip: req.ip,
    body: req.body,
    query: req.query,
    params: req.params,
  });

  // Return generic error for unexpected errors
  return res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An internal error occurred',
    },
  });
};
