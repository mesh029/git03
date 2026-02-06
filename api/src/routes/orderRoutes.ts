import { Router } from 'express';
import { orderController } from '../controllers/orderController';
import { trackingController } from '../controllers/trackingController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validator';
import { validateQuery } from '../middleware/queryValidator';
import { createOrderSchema, getOrdersQuerySchema } from '../validators/orderValidator';
import { updateOrderStatusSchema, updateLocationSchema, assignServiceProviderSchema } from '../validators/trackingValidator';
import { apiLimiter } from '../middleware/rateLimiter';
import { checkOrderLimit } from '../middleware/subscription';

const router = Router();

// All order routes require authentication
router.use(authenticate);
router.use(apiLimiter);

// Create order (with subscription limit check)
router.post(
  '/',
  validate(createOrderSchema),
  checkOrderLimit,
  orderController.createOrder.bind(orderController)
);

// Get user's orders
router.get(
  '/',
  validateQuery(getOrdersQuerySchema),
  orderController.getOrders.bind(orderController)
);

// Get single order (with ownership check via service)
router.get(
  '/:id',
  orderController.getOrder.bind(orderController)
);

// Cancel order (with ownership check via service)
router.patch(
  '/:id/cancel',
  orderController.cancelOrder.bind(orderController)
);

// Tracking endpoints
router.get(
  '/:id/tracking',
  trackingController.getOrderTracking.bind(trackingController)
);

router.get(
  '/:id/status-history',
  trackingController.getStatusHistory.bind(trackingController)
);

router.patch(
  '/:id/status',
  validate(updateOrderStatusSchema),
  trackingController.updateOrderStatus.bind(trackingController)
);

router.post(
  '/:id/tracking/location',
  validate(updateLocationSchema),
  trackingController.updateLocation.bind(trackingController)
);

router.post(
  '/:id/assign',
  validate(assignServiceProviderSchema),
  trackingController.assignServiceProvider.bind(trackingController)
);

export default router;
