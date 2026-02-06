import { Request, Response, NextFunction } from 'express';
import { orderService } from '../services/orderService';
import { CreateOrderInput, OrderStatus, OrderType } from '../models/Order';

export class OrderController {
  /**
   * Create a new order
   * POST /orders
   */
  async createOrder(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const input: CreateOrderInput = req.body;
      const order = await orderService.createOrder(input, req.user.id);

      res.status(201).json({
        success: true,
        data: order,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get user's orders
   * GET /orders
   */
  async getOrders(req: Request, res: Response, next: NextFunction): Promise<void> {
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

      const filters = {
        status: req.query.status as OrderStatus | undefined,
        type: req.query.type as OrderType | undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await orderService.getUserOrders(req.user.id, filters);

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
   * Get single order
   * GET /orders/:id
   */
  async getOrder(req: Request, res: Response, next: NextFunction): Promise<void> {
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
      const order = await orderService.getOrderById(orderId, req.user.id);

      res.status(200).json({
        success: true,
        data: order,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Cancel order
   * PATCH /orders/:id/cancel
   */
  async cancelOrder(req: Request, res: Response, next: NextFunction): Promise<void> {
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
      const order = await orderService.cancelOrder(orderId, req.user.id);

      res.status(200).json({
        success: true,
        data: order,
      });
    } catch (error) {
      next(error);
    }
  }
}

export const orderController = new OrderController();
