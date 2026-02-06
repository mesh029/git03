import { Request, Response, NextFunction } from 'express';
import pool from '../config/database';

/**
 * Middleware to authorize property access
 * Allows: Property owner (agent) OR Admin
 */
export const authorizePropertyAccess = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        error: {
          code: 'AUTH_REQUIRED',
          message: 'Authentication required',
        },
      });
      return;
    }

    const propertyId = req.params.id;

    // Get property to check ownership
    const result = await pool.query(
      'SELECT agent_id FROM properties WHERE id = $1',
      [propertyId]
    );

    if (result.rows.length === 0) {
      res.status(404).json({
        success: false,
        error: {
          code: 'PROPERTY_NOT_FOUND',
          message: 'Property not found',
        },
      });
      return;
    }

    const property = result.rows[0];
    const isOwner = property.agent_id === req.user.id;
    const isAdmin = req.user.isAdmin === true;

    // Allow if user is owner or admin
    if (!isOwner && !isAdmin) {
      res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'You can only manage your own properties',
        },
      });
      return;
    }

    next();
  } catch (error) {
    next(error);
  }
};
