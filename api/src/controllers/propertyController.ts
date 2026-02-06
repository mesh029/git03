import { Request, Response, NextFunction } from 'express';
import { propertyService } from '../services/propertyService';
import {
  CreatePropertyInput,
  UpdatePropertyInput,
  PropertyType,
} from '../models/Property';

export class PropertyController {
  /**
   * Create a new property listing
   * POST /v1/properties
   */
  async createProperty(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const input: CreatePropertyInput = req.body;
      const property = await propertyService.createProperty(input, req.user.id);

      res.status(201).json({
        success: true,
        data: property,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get properties list
   * GET /v1/properties
   */
  async getProperties(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const filters = {
        isAvailable: req.query.isAvailable !== undefined
          ? req.query.isAvailable === 'true'
          : true, // Default to available only for public
        type: req.query.type as PropertyType | undefined,
        agentId: req.query.agentId as string | undefined,
        areaLabel: req.query.areaLabel as string | undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await propertyService.getProperties(filters);

      res.status(200).json({
        success: true,
        data: {
          properties: result.properties,
          pagination: {
            limit: result.limit,
            offset: result.offset,
            total: result.total,
          },
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get single property
   * GET /v1/properties/:id
   */
  async getProperty(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const propertyId = req.params.id;
      const property = await propertyService.getPropertyById(propertyId);

      res.status(200).json({
        success: true,
        data: property,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update property
   * PATCH /v1/properties/:id
   */
  async updateProperty(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const propertyId = req.params.id;
      const input: UpdatePropertyInput = req.body;
      const isAdmin = req.user.isAdmin || false;

      const property = await propertyService.updateProperty(
        propertyId,
        input,
        req.user.id,
        isAdmin
      );

      res.status(200).json({
        success: true,
        data: property,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete property
   * DELETE /v1/properties/:id
   */
  async deleteProperty(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const propertyId = req.params.id;
      const isAdmin = req.user.isAdmin || false;

      await propertyService.deleteProperty(propertyId, req.user.id, isAdmin);

      res.status(200).json({
        success: true,
        message: 'Property deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Toggle property availability
   * PATCH /v1/properties/:id/availability
   */
  async toggleAvailability(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const propertyId = req.params.id;
      const isAdmin = req.user.isAdmin || false;

      const property = await propertyService.toggleAvailability(
        propertyId,
        req.user.id,
        isAdmin
      );

      res.status(200).json({
        success: true,
        data: property,
      });
    } catch (error) {
      next(error);
    }
  }
}

export const propertyController = new PropertyController();
