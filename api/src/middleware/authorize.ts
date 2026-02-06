import { Request, Response, NextFunction } from 'express';
import pool from '../config/database';

/**
 * Check if user owns a resource
 */
export const authorizeOwner = (resourceIdParam: string = 'id') => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
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

      const resourceId = req.params[resourceIdParam];
      const userId = req.user.id;

      // Check ownership based on route context
      // For orders, check owner_id
      if (req.path.includes('/orders')) {
        const result = await pool.query(
          'SELECT owner_id FROM orders WHERE id = $1',
          [resourceId]
        );

        if (result.rows.length === 0) {
          res.status(404).json({
            success: false,
            error: {
              code: 'ORDER_NOT_FOUND',
              message: 'Order not found',
            },
          });
          return;
        }

        if (result.rows[0].owner_id !== userId) {
          res.status(403).json({
            success: false,
            error: {
              code: 'FORBIDDEN',
              message: 'Access denied',
            },
          });
          return;
        }
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};

/**
 * Check if user is admin
 */
export const authorizeAdmin = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
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

  // Check admin status from database
  pool.query('SELECT is_admin FROM users WHERE id = $1', [req.user.id])
    .then((result) => {
      if (result.rows.length === 0 || !result.rows[0].is_admin) {
        res.status(403).json({
          success: false,
          error: {
            code: 'FORBIDDEN',
            message: 'Admin access required',
          },
        });
        return;
      }
      next();
    })
    .catch(next);
};

/**
 * Check if user is admin (alias for consistency)
 */
export const requireAdmin = authorizeAdmin;

/**
 * Check if user is agent
 */
export const authorizeAgent = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
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

  // Check agent status from database
  pool.query('SELECT is_agent FROM users WHERE id = $1', [req.user.id])
    .then((result) => {
      if (result.rows.length === 0 || !result.rows[0].is_agent) {
        res.status(403).json({
          success: false,
          error: {
            code: 'FORBIDDEN',
            message: 'Agent access required',
          },
        });
        return;
      }
      next();
    })
    .catch(next);
};

/**
 * Check if user is agent or admin
 */
export const authorizeAgentOrAdmin = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
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

  // Check agent or admin status from database
  pool.query('SELECT is_agent, is_admin FROM users WHERE id = $1', [req.user.id])
    .then((result) => {
      if (result.rows.length === 0) {
        res.status(403).json({
          success: false,
          error: {
            code: 'FORBIDDEN',
            message: 'Agent or Admin access required',
          },
        });
        return;
      }

      const user = result.rows[0];
      if (!user.is_agent && !user.is_admin) {
        res.status(403).json({
          success: false,
          error: {
            code: 'FORBIDDEN',
            message: 'Agent or Admin access required',
          },
        });
        return;
      }

      next();
    })
    .catch(next);
};
