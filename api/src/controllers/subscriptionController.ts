import { Request, Response, NextFunction } from 'express';
import { subscriptionService } from '../services/subscriptionService';
import { UpgradeSubscriptionInput, DowngradeSubscriptionInput } from '../models/Subscription';

export class SubscriptionController {
  /**
   * Get all available subscription tiers
   * GET /v1/subscriptions
   */
  async getAvailableSubscriptions(
    _req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const subscriptions = await subscriptionService.getAvailableSubscriptions();

      res.status(200).json({
        success: true,
        data: {
          subscriptions,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get user's current subscription
   * GET /v1/subscriptions/current
   */
  async getCurrentSubscription(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
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
        // Ensure user has at least freemium subscription
        const defaultSubscription = await subscriptionService.ensureUserSubscription(req.user.id);
        res.status(200).json({
          success: true,
          data: defaultSubscription,
        });
        return;
      }

      res.status(200).json({
        success: true,
        data: subscription,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Upgrade subscription
   * POST /v1/subscriptions/upgrade
   */
  async upgradeSubscription(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
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

      const input: UpgradeSubscriptionInput = req.body;
      const subscription = await subscriptionService.upgradeSubscription(req.user.id, input);

      res.status(200).json({
        success: true,
        data: subscription,
        message: 'Subscription upgraded successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Downgrade subscription
   * POST /v1/subscriptions/downgrade
   */
  async downgradeSubscription(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
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

      const input: DowngradeSubscriptionInput = req.body;
      const subscription = await subscriptionService.downgradeSubscription(req.user.id, input);

      res.status(200).json({
        success: true,
        data: subscription,
        message: 'Subscription downgraded successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Cancel subscription
   * POST /v1/subscriptions/cancel
   */
  async cancelSubscription(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
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

      const subscription = await subscriptionService.cancelSubscription(req.user.id);

      res.status(200).json({
        success: true,
        data: subscription,
        message: 'Subscription cancelled successfully. Access will continue until the end of the current billing period.',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Check feature access
   * GET /v1/subscriptions/access
   */
  async checkFeatureAccess(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
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

      const feature = req.query.feature as string;

      if (!feature) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Feature parameter is required',
          },
        });
        return;
      }

      const access = await subscriptionService.checkFeatureAccess(req.user.id, feature);

      res.status(200).json({
        success: true,
        data: access,
      });
    } catch (error) {
      next(error);
    }
  }
}

export const subscriptionController = new SubscriptionController();
