import { Request, Response, NextFunction } from 'express';
import { serviceLocationService } from '../services/serviceLocationService';
import {
  CreateServiceLocationInput,
  UpdateServiceLocationInput,
  NearbyServiceLocationQuery,
} from '../models/ServiceLocation';

export class ServiceLocationController {
  /**
   * Create a new service location
   * POST /v1/service-locations
   */
  async createServiceLocation(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const input: CreateServiceLocationInput = req.body;
      const location = await serviceLocationService.createServiceLocation(input);

      res.status(201).json({
        success: true,
        data: location,
        message: 'Service location created successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get service location by ID
   * GET /v1/service-locations/:id
   */
  async getServiceLocation(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      const location = await serviceLocationService.getServiceLocationById(id);

      res.status(200).json({
        success: true,
        data: location,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get all service locations
   * GET /v1/service-locations
   */
  async getServiceLocations(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const type = req.query.type as string | undefined;
      const city = req.query.city as string | undefined;
      const is_active = req.query.is_active === 'true' ? true : req.query.is_active === 'false' ? false : undefined;

      const locations = await serviceLocationService.getServiceLocations({
        type: type as any,
        city,
        is_active,
      });

      res.status(200).json({
        success: true,
        data: {
          locations,
          count: locations.length,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Find nearby service locations
   * GET /v1/service-locations/nearby
   */
  async findNearby(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const latitude = parseFloat(req.query.latitude as string);
      const longitude = parseFloat(req.query.longitude as string);
      const radiusKm = req.query.radius_km
        ? parseFloat(req.query.radius_km as string)
        : undefined;
      const type = req.query.type as string | undefined;
      const limit = req.query.limit
        ? parseInt(req.query.limit as string, 10)
        : undefined;

      if (isNaN(latitude) || isNaN(longitude)) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Latitude and longitude are required',
          },
        });
        return;
      }

      const query: NearbyServiceLocationQuery = {
        latitude,
        longitude,
        radius_km: radiusKm,
        type: type as any,
        limit,
      };

      const locations = await serviceLocationService.findNearbyServiceLocations(query);

      res.status(200).json({
        success: true,
        data: {
          locations,
          count: locations.length,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update service location
   * PATCH /v1/service-locations/:id
   */
  async updateServiceLocation(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      const input: UpdateServiceLocationInput = req.body;
      const location = await serviceLocationService.updateServiceLocation(id, input);

      res.status(200).json({
        success: true,
        data: location,
        message: 'Service location updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete service location
   * DELETE /v1/service-locations/:id
   */
  async deleteServiceLocation(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      const { id } = req.params;
      await serviceLocationService.deleteServiceLocation(id);

      res.status(200).json({
        success: true,
        message: 'Service location deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  }
}

export const serviceLocationController = new ServiceLocationController();
