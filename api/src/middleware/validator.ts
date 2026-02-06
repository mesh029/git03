import { Request, Response, NextFunction } from 'express';
import { Schema } from 'joi';

/**
 * Validate request body against Joi schema
 */
export const validate = (schema: Schema) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error, value } = schema.validate(req.body, {
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
          message: 'Validation failed',
          details,
        },
      });
      return;
    }

    // Replace req.body with validated and sanitized value
    req.body = value;
    next();
  };
};
