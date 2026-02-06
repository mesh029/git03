import { Request, Response, NextFunction } from 'express';
import { Schema } from 'joi';

/**
 * Validate query parameters against Joi schema
 */
export const validateQuery = (schema: Schema) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error, value } = schema.validate(req.query, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const details: Record<string, string> = {};
      error.details.forEach((detail) => {
        const key = detail.path.join('.');
        details[key] = detail.message;
      });

      res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid query parameters',
          details,
        },
      });
      return;
    }

    // Replace req.query with validated and sanitized value
    req.query = value;
    next();
  };
};
