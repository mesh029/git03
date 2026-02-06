import { Router } from 'express';
import { serviceLocationController } from '../controllers/serviceLocationController';
import { authenticate } from '../middleware/auth';
import { requireAdmin } from '../middleware/authorize';
import { validate } from '../middleware/validator';
import { validateQuery } from '../middleware/queryValidator';
import {
  createServiceLocationSchema,
  updateServiceLocationSchema,
  nearbyServiceLocationQuerySchema,
} from '../validators/serviceLocationValidator';
import { apiLimiter } from '../middleware/rateLimiter';

const router = Router();

// Public routes (no auth required)
router.get(
  '/nearby',
  validateQuery(nearbyServiceLocationQuerySchema),
  apiLimiter,
  serviceLocationController.findNearby.bind(serviceLocationController)
);

router.get(
  '/',
  apiLimiter,
  serviceLocationController.getServiceLocations.bind(serviceLocationController)
);

router.get(
  '/:id',
  apiLimiter,
  serviceLocationController.getServiceLocation.bind(serviceLocationController)
);

// Admin-only routes
router.use(authenticate);
router.use(requireAdmin);

router.post(
  '/',
  validate(createServiceLocationSchema),
  apiLimiter,
  serviceLocationController.createServiceLocation.bind(serviceLocationController)
);

router.patch(
  '/:id',
  validate(updateServiceLocationSchema),
  apiLimiter,
  serviceLocationController.updateServiceLocation.bind(serviceLocationController)
);

router.delete(
  '/:id',
  apiLimiter,
  serviceLocationController.deleteServiceLocation.bind(serviceLocationController)
);

export default router;
