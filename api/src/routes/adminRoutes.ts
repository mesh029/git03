import { Router } from 'express';
import { adminController } from '../controllers/adminController';
import { authenticate } from '../middleware/auth';
import { authorizeAdmin } from '../middleware/authorize';
import { validate } from '../middleware/validator';
import { validateQuery } from '../middleware/queryValidator';
import {
  updateUserRoleSchema,
  updateOrderStatusSchema,
  adminUsersQuerySchema,
  adminOrdersQuerySchema,
  adminPropertiesQuerySchema,
  adminSubscriptionsQuerySchema,
  updateSubscriptionStatusSchema,
} from '../validators/adminValidator';
import { apiLimiter } from '../middleware/rateLimiter';

const router = Router();

// All admin routes require authentication and admin role
router.use(authenticate);
router.use(authorizeAdmin);
router.use(apiLimiter);

// User Management
router.get(
  '/users',
  validateQuery(adminUsersQuerySchema),
  adminController.getUsers.bind(adminController)
);

router.get(
  '/users/:id',
  adminController.getUser.bind(adminController)
);

router.patch(
  '/users/:id/role',
  validate(updateUserRoleSchema),
  adminController.updateUserRole.bind(adminController)
);

router.get(
  '/users/:id/orders',
  validateQuery(adminOrdersQuerySchema),
  adminController.getUserOrders.bind(adminController)
);

router.get(
  '/users/:id/properties',
  validateQuery(adminPropertiesQuerySchema),
  adminController.getUserProperties.bind(adminController)
);

// Order Management
router.get(
  '/orders',
  validateQuery(adminOrdersQuerySchema),
  adminController.getOrders.bind(adminController)
);

router.patch(
  '/orders/:id/status',
  validate(updateOrderStatusSchema),
  adminController.updateOrderStatus.bind(adminController)
);

// Property Management
router.get(
  '/properties',
  validateQuery(adminPropertiesQuerySchema),
  adminController.getProperties.bind(adminController)
);

// Platform Statistics
router.get(
  '/stats',
  adminController.getStats.bind(adminController)
);

// Subscription Management
router.get(
  '/subscriptions',
  validateQuery(adminSubscriptionsQuerySchema),
  adminController.getSubscriptions.bind(adminController)
);

router.get(
  '/subscriptions/:id',
  adminController.getSubscription.bind(adminController)
);

router.patch(
  '/subscriptions/:id/status',
  validate(updateSubscriptionStatusSchema),
  adminController.updateSubscriptionStatus.bind(adminController)
);

export default router;
