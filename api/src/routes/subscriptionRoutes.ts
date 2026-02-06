import { Router } from 'express';
import { subscriptionController } from '../controllers/subscriptionController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validator';
import { validateQuery } from '../middleware/queryValidator';
import {
  upgradeSubscriptionSchema,
  downgradeSubscriptionSchema,
  checkAccessQuerySchema,
} from '../validators/subscriptionValidator';
import { apiLimiter } from '../middleware/rateLimiter';

const router = Router();

// Public route - list available subscriptions
router.get(
  '/',
  apiLimiter,
  subscriptionController.getAvailableSubscriptions.bind(subscriptionController)
);

// Protected routes - require authentication
router.use(authenticate);
router.use(apiLimiter);

// Get current subscription
router.get(
  '/current',
  subscriptionController.getCurrentSubscription.bind(subscriptionController)
);

// Upgrade subscription
router.post(
  '/upgrade',
  validate(upgradeSubscriptionSchema),
  subscriptionController.upgradeSubscription.bind(subscriptionController)
);

// Downgrade subscription
router.post(
  '/downgrade',
  validate(downgradeSubscriptionSchema),
  subscriptionController.downgradeSubscription.bind(subscriptionController)
);

// Cancel subscription
router.post(
  '/cancel',
  subscriptionController.cancelSubscription.bind(subscriptionController)
);

// Check feature access
router.get(
  '/access',
  validateQuery(checkAccessQuerySchema),
  subscriptionController.checkFeatureAccess.bind(subscriptionController)
);

export default router;
