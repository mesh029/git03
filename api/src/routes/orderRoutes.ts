import { Router } from 'express';
import { orderController } from '../controllers/orderController';
import { authenticate } from '../middleware/auth';
import { authorizeOwner } from '../middleware/authorize';
import { validate } from '../middleware/validator';
import { validateQuery } from '../middleware/queryValidator';
import { createOrderSchema, getOrdersQuerySchema } from '../validators/orderValidator';
import { apiLimiter } from '../middleware/rateLimiter';

const router = Router();

// All order routes require authentication
router.use(authenticate);
router.use(apiLimiter);

// Create order
router.post(
  '/',
  validate(createOrderSchema),
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

export default router;
