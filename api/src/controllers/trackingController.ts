import { Request, Response, NextFunction } from 'express';
import { trackingService } from '../services/trackingService';
import { UpdateOrderStatusInput, UpdateLocationInput } from '../models/Tracking';

export class TrackingController {
  /**
   * Get order tracking information
   * GET /v1/orders/:id/tracking
   */
  async getOrderTracking(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const orderId = req.params.id;
      const tracking = await trackingService.getOrderTracking(orderId, req.user.id);

      res.status(200).json({
        success: true,
        data: tracking,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update order status
   * PATCH /v1/orders/:id/status
   */
  async updateOrderStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const orderId = req.params.id;
      const input: UpdateOrderStatusInput = req.body;
      const tracking = await trackingService.updateOrderStatus(orderId, req.user.id, input);

      res.status(200).json({
        success: true,
        data: tracking,
        message: 'Order status updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get order status history
   * GET /v1/orders/:id/status-history
   */
  async getStatusHistory(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const orderId = req.params.id;
      const history = await trackingService.getStatusHistory(orderId, req.user.id);

      res.status(200).json({
        success: true,
        data: {
          history,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update service provider location
   * POST /v1/orders/:id/tracking/location
   */
  async updateLocation(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const orderId = req.params.id;
      const input: UpdateLocationInput = req.body;
      const tracking = await trackingService.updateServiceProviderLocation(orderId, req.user.id, input);

      res.status(200).json({
        success: true,
        data: tracking,
        message: 'Location updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Assign service provider to order
   * POST /v1/orders/:id/assign
   */
  async assignServiceProvider(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const orderId = req.params.id;
      const { serviceProviderId } = req.body;

      await trackingService.assignServiceProvider(orderId, serviceProviderId, req.user.id);

      const tracking = await trackingService.getOrderTracking(orderId, req.user.id);

      res.status(200).json({
        success: true,
        data: tracking,
        message: 'Service provider assigned successfully',
      });
    } catch (error) {
      next(error);
    }
  }
}

export const trackingController = new TrackingController();
