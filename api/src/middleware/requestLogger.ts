import { Request, Response, NextFunction } from 'express';
import { logRequest } from '../utils/logger';

/**
 * Request logging middleware
 * Logs all incoming HTTP requests with method, URL, status code, response time, and user info
 */
export const requestLogger = (req: Request, res: Response, next: NextFunction): void => {
  const startTime = Date.now();

  // Override res.end to capture response time
  const originalEnd = res.end.bind(res);
  res.end = function (chunk?: any, encoding?: any, cb?: any) {
    const responseTime = Date.now() - startTime;
    logRequest(req, res, responseTime);
    
    if (typeof encoding === 'function') {
      return originalEnd(chunk, encoding);
    }
    if (typeof cb === 'function') {
      return originalEnd(chunk, encoding, cb);
    }
    return originalEnd(chunk, encoding);
  };

  next();
};
