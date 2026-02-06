import { Request, Response, NextFunction } from 'express';
import { subscriptionService } from '../services/subscriptionService';
import { AuthorizationError, ValidationError } from '../utils/errors';
import { SubscriptionTier } from '../models/Subscription';

/**
 * Middleware to require a minimum subscription tier
 */
export const requireSubscription = (minTier: SubscriptionTier) => {
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

      const subscription = await subscriptionService.getCurrentSubscription(req.user.id);
      
      if (!subscription) {
        // Ensure user has at least freemium
        await subscriptionService.ensureUserSubscription(req.user.id);
        const freemiumSubscription = await subscriptionService.getCurrentSubscription(req.user.id);
        
        if (!freemiumSubscription || !hasMinimumTier(freemiumSubscription.tier, minTier)) {
          throw new AuthorizationError(
            `This feature requires ${minTier} subscription or higher`
          );
        }
      } else {
        if (!hasMinimumTier(subscription.tier, minTier)) {
          throw new AuthorizationError(
            `This feature requires ${minTier} subscription or higher`
          );
        }
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};

/**
 * Middleware to require a specific feature access
 */
export const requireFeature = (feature: string) => {
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

      const access = await subscriptionService.checkFeatureAccess(req.user.id, feature);

      if (!access.hasAccess) {
        throw new AuthorizationError(
          `Feature '${feature}' is not available with your current subscription`
        );
      }

      // Check if limit is exceeded
      const remaining = access.remaining;
      if (access.limit !== null && remaining !== undefined && remaining !== null && remaining <= 0) {
        throw new ValidationError(
          `You have reached your limit for '${feature}'. Upgrade your subscription for more access.`
        );
      }

      // Attach access info to request for use in controllers
      req.subscriptionAccess = access;

      next();
    } catch (error) {
      next(error);
    }
  };
};

/**
 * Middleware to check subscription limits before order creation
 */
export const checkOrderLimit = async (
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

    const orderType = req.body.type;
    
    // Determine which feature to check based on order type
    let feature: string;
    if (orderType === 'cleaning') {
      feature = 'cleaning_orders_per_month';
    } else if (orderType === 'laundry') {
      feature = 'laundry_orders_per_month';
    } else if (orderType === 'property_booking') {
      feature = 'property_bookings_per_month';
    } else {
      feature = 'orders_per_month';
    }

    // Check general orders limit first
    const generalAccess = await subscriptionService.checkFeatureAccess(req.user.id, 'orders_per_month');
    const generalRemaining: number | null | undefined = generalAccess.remaining;
    
    if (generalAccess.limit !== null && typeof generalRemaining === 'number' && generalRemaining <= 0) {
      throw new ValidationError(
        `You have reached your monthly order limit (${generalAccess.limit}). Upgrade your subscription for unlimited orders.`
      );
    }

    // Check specific order type limit if it exists
    if (orderType !== 'cleaning' && orderType !== 'laundry' && orderType !== 'property_booking') {
      // For general orders, check the general limit
      if (generalAccess.limit !== null && typeof generalRemaining === 'number' && generalRemaining <= 0) {
        throw new ValidationError(
          `You have reached your monthly order limit (${generalAccess.limit}). Upgrade your subscription for unlimited orders.`
        );
      }
    } else {
      // Check specific service limit
      const specificAccess = await subscriptionService.checkFeatureAccess(req.user.id, feature);
      const specificRemaining: number | null | undefined = specificAccess.remaining;
      
      if (specificAccess.hasAccess && specificAccess.limit === null) {
        // Unlimited for this service type
        next();
        return;
      }

      // If specific limit exists and is exceeded, check general limit
      if (specificAccess.limit !== null && typeof specificRemaining === 'number' && specificRemaining <= 0) {
        // Fall back to general limit
        if (generalAccess.limit !== null && typeof generalRemaining === 'number' && generalRemaining <= 0) {
          throw new ValidationError(
            `You have reached your monthly order limit. Upgrade your subscription for unlimited orders.`
          );
        }
      }
    }

    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Helper function to check if user has minimum tier
 */
function hasMinimumTier(userTier: SubscriptionTier, minTier: SubscriptionTier): boolean {
  const tierHierarchy: Record<SubscriptionTier, number> = {
    [SubscriptionTier.FREEMIUM]: 0,
    [SubscriptionTier.CLEANING]: 1,
    [SubscriptionTier.LAUNDRY]: 1,
    [SubscriptionTier.PROPERTY_BOOKING]: 1,
    [SubscriptionTier.COMBINED]: 2,
    [SubscriptionTier.PREMIUM]: 2,
  };

  return tierHierarchy[userTier] >= tierHierarchy[minTier];
}

// Extend Express Request to include subscription access
declare global {
  namespace Express {
    interface Request {
      subscriptionAccess?: {
        hasAccess: boolean;
        limit?: number | null;
        used?: number;
        remaining?: number | null;
      };
    }
  }
}
