import { Request, Response, NextFunction } from 'express';
import { adminService } from '../services/adminService';
import { OrderStatus, OrderType } from '../models/Order';
import { PropertyType } from '../models/Property';
import { SubscriptionStatus, SubscriptionTier } from '../models/Subscription';

export class AdminController {
  /**
   * Get all users
   * GET /v1/admin/users
   */
  async getUsers(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const filters = {
        role: req.query.role as 'regular' | 'agent' | 'admin' | undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await adminService.getUsers(filters);

      res.status(200).json({
        success: true,
        data: {
          users: result.users,
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
   * Get user by ID
   * GET /v1/admin/users/:id
   */
  async getUser(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.params.id;
      const user = await adminService.getUserById(userId);

      res.status(200).json({
        success: true,
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update user role
   * PATCH /v1/admin/users/:id/role
   */
  async updateUserRole(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.params.id;
      const { isAdmin, isAgent } = req.body;

      await adminService.updateUserRole(userId, {
        isAdmin,
        isAgent,
      });

      res.status(200).json({
        success: true,
        message: 'User role updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get user's orders
   * GET /v1/admin/users/:id/orders
   */
  async getUserOrders(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.params.id;
      const filters = {
        userId,
        status: req.query.status as OrderStatus | undefined,
        type: req.query.type as OrderType | undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await adminService.getAllOrders(filters);

      res.status(200).json({
        success: true,
        data: {
          orders: result.orders,
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
   * Get user's properties (if agent)
   * GET /v1/admin/users/:id/properties
   */
  async getUserProperties(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.params.id;
      const filters = {
        agentId: userId,
        isAvailable: req.query.isAvailable !== undefined
          ? req.query.isAvailable === 'true'
          : undefined,
        type: req.query.type as PropertyType | undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await adminService.getAllProperties(filters);

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
   * Get all orders
   * GET /v1/admin/orders
   */
  async getOrders(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const filters = {
        status: req.query.status as OrderStatus | undefined,
        type: req.query.type as OrderType | undefined,
        userId: req.query.userId as string | undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await adminService.getAllOrders(filters);

      res.status(200).json({
        success: true,
        data: {
          orders: result.orders,
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
   * Update order status
   * PATCH /v1/admin/orders/:id/status
   */
  async updateOrderStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const orderId = req.params.id;
      const { status } = req.body;

      if (!status || (status !== OrderStatus.PENDING && status !== OrderStatus.CANCELLED)) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid status. Must be pending or cancelled',
          },
        });
        return;
      }

      await adminService.updateOrderStatus(orderId, status);

      res.status(200).json({
        success: true,
        message: 'Order status updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get all properties
   * GET /v1/admin/properties
   */
  async getProperties(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const filters = {
        isAvailable: req.query.isAvailable !== undefined
          ? req.query.isAvailable === 'true'
          : undefined,
        type: req.query.type as PropertyType | undefined,
        agentId: req.query.agentId as string | undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await adminService.getAllProperties(filters);

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
   * Get platform statistics
   * GET /v1/admin/stats
   */
  async getStats(_req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const stats = await adminService.getPlatformStats();

      res.status(200).json({
        success: true,
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get all subscriptions
   * GET /v1/admin/subscriptions
   */
  async getSubscriptions(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const filters = {
        status: req.query.status as SubscriptionStatus | undefined,
        tier: req.query.tier as SubscriptionTier | undefined,
        userId: req.query.userId as string | undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await adminService.getSubscriptions(filters);

      res.status(200).json({
        success: true,
        data: {
          subscriptions: result.subscriptions,
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
   * Get subscription by ID
   * GET /v1/admin/subscriptions/:id
   */
  async getSubscription(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const subscriptionId = req.params.id;
      const subscription = await adminService.getSubscriptionById(subscriptionId);

      res.status(200).json({
        success: true,
        data: subscription,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update subscription status
   * PATCH /v1/admin/subscriptions/:id/status
   */
  async updateSubscriptionStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const subscriptionId = req.params.id;
      const { status } = req.body;

      await adminService.updateSubscriptionStatus(subscriptionId, status);

      res.status(200).json({
        success: true,
        message: 'Subscription status updated successfully',
      });
    } catch (error) {
      next(error);
    }
  }
}

export const adminController = new AdminController();
