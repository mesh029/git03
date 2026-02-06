import { Router } from 'express';
import { locationController } from '../controllers/locationController';
import { validateQuery } from '../middleware/queryValidator';
import {
  geocodeQuerySchema,
  reverseGeocodeQuerySchema,
  distanceQuerySchema,
  validateCoordinatesQuerySchema,
} from '../validators/locationValidator';
import { apiLimiter } from '../middleware/rateLimiter';

const router = Router();

// All location routes are public but rate-limited
router.use(apiLimiter);

// Geocode: Address → Coordinates
router.get(
  '/geocode',
  validateQuery(geocodeQuerySchema),
  locationController.geocode.bind(locationController)
);

// Reverse Geocode: Coordinates → Address
router.get(
  '/reverse-geocode',
  validateQuery(reverseGeocodeQuerySchema),
  locationController.reverseGeocode.bind(locationController)
);

// Calculate Distance
router.get(
  '/distance',
  validateQuery(distanceQuerySchema),
  locationController.calculateDistance.bind(locationController)
);

// Validate Coordinates
router.get(
  '/validate',
  validateQuery(validateCoordinatesQuerySchema),
  locationController.validateCoordinates.bind(locationController)
);

export default router;
