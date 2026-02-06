import { Request, Response, NextFunction } from 'express';
import { mapboxService } from '../services/mapboxService';

export class LocationController {
  /**
   * Geocode: Convert address to coordinates
   * GET /v1/locations/geocode?address=...
   */
  async geocode(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { address, country } = req.query;

      if (!address || typeof address !== 'string') {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Address query parameter is required',
            details: {
              address: 'Address is required',
            },
          },
        });
        return;
      }

      const countryCode = (country as string) || 'KE';
      const result = await mapboxService.geocode(address, countryCode);

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Reverse Geocode: Convert coordinates to address
   * GET /v1/locations/reverse-geocode?lat=...&lng=...
   */
  async reverseGeocode(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { lat, lng } = req.query;

      if (!lat || !lng) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Latitude and longitude query parameters are required',
            details: {
              lat: lat ? undefined : 'Latitude is required',
              lng: lng ? undefined : 'Longitude is required',
            },
          },
        });
        return;
      }

      const latitude = parseFloat(lat as string);
      const longitude = parseFloat(lng as string);

      if (isNaN(latitude) || isNaN(longitude)) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid coordinates',
            details: {
              lat: isNaN(latitude) ? 'Latitude must be a number' : undefined,
              lng: isNaN(longitude) ? 'Longitude must be a number' : undefined,
            },
          },
        });
        return;
      }

      const result = await mapboxService.reverseGeocode(latitude, longitude);

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Calculate distance between two points
   * GET /v1/locations/distance?fromLat=...&fromLng=...&toLat=...&toLng=...
   */
  async calculateDistance(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { fromLat, fromLng, toLat, toLng } = req.query;

      if (!fromLat || !fromLng || !toLat || !toLng) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'All coordinate parameters are required',
            details: {
              fromLat: fromLat ? undefined : 'fromLat is required',
              fromLng: fromLng ? undefined : 'fromLng is required',
              toLat: toLat ? undefined : 'toLat is required',
              toLng: toLng ? undefined : 'toLng is required',
            },
          },
        });
        return;
      }

      const lat1 = parseFloat(fromLat as string);
      const lon1 = parseFloat(fromLng as string);
      const lat2 = parseFloat(toLat as string);
      const lon2 = parseFloat(toLng as string);

      if (isNaN(lat1) || isNaN(lon1) || isNaN(lat2) || isNaN(lon2)) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid coordinates',
          },
        });
        return;
      }

      const result = await mapboxService.calculateDistance(lat1, lon1, lat2, lon2);

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Validate coordinates
   * GET /v1/locations/validate?lat=...&lng=...
   */
  async validateCoordinates(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { lat, lng } = req.query;

      if (!lat || !lng) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Latitude and longitude query parameters are required',
          },
        });
        return;
      }

      const latitude = parseFloat(lat as string);
      const longitude = parseFloat(lng as string);

      if (isNaN(latitude) || isNaN(longitude)) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid coordinates',
          },
        });
        return;
      }

      const validation = mapboxService.validateCoordinates(latitude, longitude);

      res.status(200).json({
        success: true,
        data: validation,
      });
    } catch (error) {
      next(error);
    }
  }
}

export const locationController = new LocationController();
