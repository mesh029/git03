import { Server as HttpServer } from 'http';
import { Server as SocketIOServer, Socket } from 'socket.io';
import { authService } from './authService';
import { OrderTrackingResponse } from '../models/Tracking';
import { logInfo, logWarn, logError, logDebug } from '../utils/logger';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  userEmail?: string;
}

export class WebSocketService {
  private io: SocketIOServer | null = null;
  private orderRooms: Map<string, Set<string>> = new Map(); // orderId -> Set of socketIds

  /**
   * Initialize WebSocket server
   */
  initialize(httpServer: HttpServer): void {
    this.io = new SocketIOServer(httpServer, {
      cors: {
        origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
        credentials: true,
      },
      path: '/socket.io',
    });

    // Authentication middleware
    this.io.use(async (socket: AuthenticatedSocket, next) => {
      try {
        const token = socket.handshake.auth?.token || socket.handshake.headers?.authorization?.replace('Bearer ', '');
        
        if (!token) {
          return next(new Error('Authentication token required'));
        }

        const payload = authService.verifyToken(token);
        socket.userId = payload.sub;
        socket.userEmail = payload.email;
        
        next();
      } catch (error) {
        next(new Error('Authentication failed'));
      }
    });

    // Connection handler
    this.io.on('connection', (socket: AuthenticatedSocket) => {
      logInfo('WebSocket client connected', {
        userId: socket.userId,
        socketId: socket.id,
        userEmail: socket.userEmail,
      });

      // Join order room
      socket.on('join_order', async (orderId: string) => {
        try {
          // Verify user has access to this order
          const hasAccess = await this.verifyOrderAccess(orderId, socket.userId!);
          
          if (!hasAccess) {
            socket.emit('error', {
              code: 'ACCESS_DENIED',
              message: 'You do not have access to this order',
            });
            return;
          }

          socket.join(`order:${orderId}`);
          
          // Track socket in order room
          if (!this.orderRooms.has(orderId)) {
            this.orderRooms.set(orderId, new Set());
          }
          this.orderRooms.get(orderId)!.add(socket.id);

          socket.emit('joined_order', { orderId });
          logDebug('Socket joined order room', {
            socketId: socket.id,
            userId: socket.userId,
            orderId,
          });
        } catch (error) {
          socket.emit('error', {
            code: 'JOIN_FAILED',
            message: error instanceof Error ? error.message : 'Failed to join order room',
          });
        }
      });

      // Leave order room
      socket.on('leave_order', (orderId: string) => {
        socket.leave(`order:${orderId}`);
        
        const room = this.orderRooms.get(orderId);
        if (room) {
          room.delete(socket.id);
          if (room.size === 0) {
            this.orderRooms.delete(orderId);
          }
        }

        socket.emit('left_order', { orderId });
        logDebug('Socket left order room', {
          socketId: socket.id,
          userId: socket.userId,
          orderId,
        });
      });

      // Disconnect handler
      socket.on('disconnect', () => {
        logInfo('WebSocket client disconnected', {
          userId: socket.userId,
          socketId: socket.id,
        });
        
        // Clean up order rooms
        for (const [orderId, sockets] of this.orderRooms.entries()) {
          sockets.delete(socket.id);
          if (sockets.size === 0) {
            this.orderRooms.delete(orderId);
          }
        }
      });
    });
  }

  /**
   * Broadcast order tracking update to all clients in order room
   */
  broadcastOrderUpdate(orderId: string, tracking: OrderTrackingResponse): void {
    if (!this.io) {
      logWarn('WebSocket server not initialized');
      return;
    }

    this.io.to(`order:${orderId}`).emit('order_update', {
      orderId,
      tracking,
      timestamp: new Date().toISOString(),
    });

    logDebug('Broadcasted order update', { orderId });
  }

  /**
   * Broadcast order status change
   */
  broadcastStatusChange(orderId: string, status: string, updatedBy: string): void {
    if (!this.io) {
      logWarn('WebSocket server not initialized');
      return;
    }

    this.io.to(`order:${orderId}`).emit('order_status_changed', {
      orderId,
      status,
      updatedBy,
      timestamp: new Date().toISOString(),
    });

    logInfo('Broadcasted status change', {
      orderId,
      status,
      updatedBy,
    });
  }

  /**
   * Broadcast location update
   */
  broadcastLocationUpdate(orderId: string, location: { latitude: number; longitude: number; label?: string }): void {
    if (!this.io) {
      logWarn('WebSocket server not initialized');
      return;
    }

    this.io.to(`order:${orderId}`).emit('location_update', {
      orderId,
      location,
      timestamp: new Date().toISOString(),
    });

    logDebug('Broadcasted location update', { orderId });
  }

  /**
   * Verify user has access to order
   */
  private async verifyOrderAccess(orderId: string, userId: string): Promise<boolean> {
    try {
      const pool = (await import('../config/database')).default;
      const result = await pool.query(
        `SELECT o.owner_id, u.is_admin, ot.service_provider_id
         FROM orders o
         LEFT JOIN users u ON u.id = $1
         LEFT JOIN order_tracking ot ON ot.order_id = o.id
         WHERE o.id = $2`,
        [userId, orderId]
      );

      if (result.rows.length === 0) {
        return false;
      }

      const order = result.rows[0];
      
      // Owner, admin, or service provider can access
      return (
        order.owner_id === userId ||
        order.is_admin === true ||
        order.service_provider_id === userId
      );
    } catch (error) {
      logError(error as Error, {
        context: 'verify_order_access',
        orderId,
        userId,
      });
      return false;
    }
  }

  /**
   * Get WebSocket server instance
   */
  getIO(): SocketIOServer | null {
    return this.io;
  }

  /**
   * Get connected clients count for an order
   */
  getOrderRoomSize(orderId: string): number {
    if (!this.io) {
      return 0;
    }
    
    const room = this.io.sockets.adapter.rooms.get(`order:${orderId}`);
    return room ? room.size : 0;
  }
}

export const webSocketService = new WebSocketService();
