import { Router } from 'express';
import { propertyController } from '../controllers/propertyController';
import { propertyImageController, uploadPropertyImage } from '../controllers/propertyImageController';
import { authenticate } from '../middleware/auth';
import { authorizeAgentOrAdmin } from '../middleware/authorize';
import { authorizePropertyAccess } from '../middleware/propertyAuthorization';
import { validate } from '../middleware/validator';
import { validateQuery } from '../middleware/queryValidator';
import {
  createPropertySchema,
  updatePropertySchema,
  getPropertiesQuerySchema,
} from '../validators/propertyValidator';
import { apiLimiter } from '../middleware/rateLimiter';

const router = Router();

// Public routes (no auth required)
router.get(
  '/',
  validateQuery(getPropertiesQuerySchema),
  apiLimiter,
  propertyController.getProperties.bind(propertyController)
);

router.get(
  '/:id',
  apiLimiter,
  propertyController.getProperty.bind(propertyController)
);

// Protected routes (require authentication)
router.use(authenticate);
router.use(apiLimiter);

// Create property (Agent or Admin)
router.post(
  '/',
  authorizeAgentOrAdmin,
  validate(createPropertySchema),
  propertyController.createProperty.bind(propertyController)
);

// Update property (Agent owner or Admin)
router.patch(
  '/:id',
  validate(updatePropertySchema),
  propertyController.updateProperty.bind(propertyController)
);

// Delete property (Agent owner or Admin)
router.delete(
  '/:id',
  propertyController.deleteProperty.bind(propertyController)
);

// Toggle availability (Agent owner or Admin)
router.patch(
  '/:id/availability',
  propertyController.toggleAvailability.bind(propertyController)
);

// Image upload routes
// Authorization: Property owner (agent) OR Admin
router.post(
  '/:id/images',
  authorizeAgentOrAdmin, // First check: Must be agent or admin
  authorizePropertyAccess, // Second check: Must own property OR be admin
  uploadPropertyImage,
  propertyImageController.uploadImage.bind(propertyImageController)
);

router.delete(
  '/:id/images/:imageIndex',
  authorizeAgentOrAdmin, // First check: Must be agent or admin
  authorizePropertyAccess, // Second check: Must own property OR be admin
  propertyImageController.deleteImage.bind(propertyImageController)
);

export default router;
