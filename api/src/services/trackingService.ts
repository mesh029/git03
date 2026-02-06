import pool from '../config/database';
import {
  OrderStatusHistory,
  OrderTracking,
  StatusHistoryResponse,
  OrderTrackingResponse,
  UpdateOrderStatusInput,
  UpdateLocationInput,
  TrackingLocation,
} from '../models/Tracking';
import { OrderStatus } from '../models/Order';
import { NotFoundError, ValidationError, AuthorizationError } from '../utils/errors';
import { webSocketService } from './websocketService';

export class TrackingService {
  /**
   * Get order tracking information
   */
  async getOrderTracking(orderId: string, userId: string): Promise<OrderTrackingResponse> {
    // Check order exists and user has access
    const orderResult = await pool.query(
      'SELECT id, owner_id, status FROM orders WHERE id = $1',
      [orderId]
    );

    if (orderResult.rows.length === 0) {
      throw new NotFoundError('Order');
    }

    const order = orderResult.rows[0];

    // Check authorization (owner or admin)
    const userResult = await pool.query(
      'SELECT id, is_admin FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      throw new NotFoundError('User');
    }

    const user = userResult.rows[0];

    if (order.owner_id !== userId && !user.is_admin) {
      throw new AuthorizationError('Access denied');
    }

    // Get tracking info
    const trackingResult = await pool.query(
      'SELECT * FROM order_tracking WHERE order_id = $1',
      [orderId]
    );

    if (trackingResult.rows.length === 0) {
      // Create tracking if it doesn't exist (shouldn't happen with trigger, but safety check)
      await pool.query(
        'INSERT INTO order_tracking (order_id) VALUES ($1)',
        [orderId]
      );
      const newTrackingResult = await pool.query(
        'SELECT * FROM order_tracking WHERE order_id = $1',
        [orderId]
      );
      const tracking = newTrackingResult.rows[0] as OrderTracking;
      return await this.buildTrackingResponse(orderId, order.status, tracking);
    }

    const tracking = trackingResult.rows[0] as OrderTracking;
    return await this.buildTrackingResponse(orderId, order.status, tracking);
  }

  /**
   * Update order status
   */
  async updateOrderStatus(
    orderId: string,
    userId: string,
    input: UpdateOrderStatusInput
  ): Promise<OrderTrackingResponse> {
    // Validate status transition
    const orderResult = await pool.query(
      'SELECT id, owner_id, status FROM orders WHERE id = $1',
      [orderId]
    );

    if (orderResult.rows.length === 0) {
      throw new NotFoundError('Order');
    }

    const order = orderResult.rows[0];

    // Check authorization
    const userResult = await pool.query(
      'SELECT id, is_admin, is_agent FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      throw new NotFoundError('User');
    }

    const user = userResult.rows[0];

    // Check if user can update this order
    const canUpdate = user.is_admin || 
                      order.owner_id === userId ||
                      await this.isServiceProviderForOrder(orderId, userId);

    if (!canUpdate) {
      throw new AuthorizationError('You do not have permission to update this order status');
    }

    // Validate status transition
    this.validateStatusTransition(order.status, input.status);

    // Update order status
    await pool.query(
      'UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2',
      [input.status, orderId]
    );

    // Record status history
    await pool.query(
      `INSERT INTO order_status_history (order_id, status, updated_by, notes)
       VALUES ($1, $2, $3, $4)`,
      [orderId, input.status, userId, input.notes || null]
    );

    // Get updated tracking
    const tracking = await this.getOrderTracking(orderId, userId);

    // Broadcast WebSocket event
    webSocketService.broadcastStatusChange(orderId, input.status, userId);
    webSocketService.broadcastOrderUpdate(orderId, tracking);

    return tracking;
  }

  /**
   * Get order status history
   */
  async getStatusHistory(orderId: string, userId: string): Promise<StatusHistoryResponse[]> {
    // Check authorization
    await this.getOrderTracking(orderId, userId);

    const result = await pool.query(
      `SELECT * FROM order_status_history
       WHERE order_id = $1
       ORDER BY created_at ASC`,
      [orderId]
    );

    return result.rows.map((row: OrderStatusHistory) => ({
      id: row.id,
      status: row.status,
      updatedBy: row.updated_by,
      notes: row.notes,
      createdAt: row.created_at.toISOString(),
    }));
  }

  /**
   * Update service provider location
   */
  async updateServiceProviderLocation(
    orderId: string,
    userId: string,
    input: UpdateLocationInput
  ): Promise<OrderTrackingResponse> {
    // Check if user is service provider for this order
    const isServiceProvider = await this.isServiceProviderForOrder(orderId, userId);

    if (!isServiceProvider) {
      throw new AuthorizationError('You are not assigned as service provider for this order');
    }

    // Validate location
    if (input.latitude < -90 || input.latitude > 90) {
      throw new ValidationError('Invalid latitude');
    }

    if (input.longitude < -180 || input.longitude > 180) {
      throw new ValidationError('Invalid longitude');
    }

    // Update tracking location
    await pool.query(
      `UPDATE order_tracking
       SET current_location_latitude = $1,
           current_location_longitude = $2,
           current_location_label = $3,
           last_updated_at = NOW()
       WHERE order_id = $4`,
      [input.latitude, input.longitude, input.label || null, orderId]
    );

    // Get order to calculate ETA (future enhancement)
    // For now, location update is sufficient
    // ETA calculation can be added later using distance calculation

    const tracking = await this.getOrderTracking(orderId, userId);

    // Broadcast WebSocket event
    webSocketService.broadcastLocationUpdate(orderId, {
      latitude: input.latitude,
      longitude: input.longitude,
      label: input.label,
    });
    webSocketService.broadcastOrderUpdate(orderId, tracking);

    return tracking;
  }

  /**
   * Assign service provider to order
   */
  async assignServiceProvider(
    orderId: string,
    serviceProviderId: string,
    assignedBy: string
  ): Promise<void> {
    // Check order exists
    const orderResult = await pool.query('SELECT id FROM orders WHERE id = $1', [orderId]);
    if (orderResult.rows.length === 0) {
      throw new NotFoundError('Order');
    }

    // Check service provider exists and is agent
    const providerResult = await pool.query(
      'SELECT id, is_agent FROM users WHERE id = $1',
      [serviceProviderId]
    );

    if (providerResult.rows.length === 0) {
      throw new NotFoundError('Service provider');
    }

    if (!providerResult.rows[0].is_agent) {
      throw new ValidationError('User is not an agent/service provider');
    }

    // Update tracking
    await pool.query(
      `UPDATE order_tracking
       SET service_provider_id = $1,
           last_updated_at = NOW()
       WHERE order_id = $2`,
      [serviceProviderId, orderId]
    );

    // Update order status to assigned
    await pool.query(
      'UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2',
      [OrderStatus.ASSIGNED, orderId]
    );

    // Record status change
    await pool.query(
      `INSERT INTO order_status_history (order_id, status, updated_by, notes)
       VALUES ($1, $2, $3, $4)`,
      [orderId, OrderStatus.ASSIGNED, assignedBy, `Assigned to service provider ${serviceProviderId}`]
    );

    // Broadcast WebSocket event
    webSocketService.broadcastStatusChange(orderId, OrderStatus.ASSIGNED, assignedBy);
    
    // Get updated tracking and broadcast
    const tracking = await this.getOrderTracking(orderId, assignedBy);
    webSocketService.broadcastOrderUpdate(orderId, tracking);
  }

  /**
   * Build tracking response
   */
  private async buildTrackingResponse(
    orderId: string,
    currentStatus: OrderStatus,
    tracking: OrderTracking
  ): Promise<OrderTrackingResponse> {
    // Get status history
    const historyResult = await pool.query(
      `SELECT * FROM order_status_history
       WHERE order_id = $1
       ORDER BY created_at ASC`,
      [orderId]
    );

    const statusHistory: StatusHistoryResponse[] = historyResult.rows.map((row: OrderStatusHistory) => ({
      id: row.id,
      status: row.status,
      updatedBy: row.updated_by,
      notes: row.notes,
      createdAt: row.created_at.toISOString(),
    }));

    // Get service provider info if assigned
    let serviceProvider = null;
    if (tracking.service_provider_id) {
      const providerResult = await pool.query(
        'SELECT id, name, email FROM users WHERE id = $1',
        [tracking.service_provider_id]
      );

      if (providerResult.rows.length > 0) {
        const provider = providerResult.rows[0];
        serviceProvider = {
          id: provider.id,
          name: provider.name,
          email: provider.email,
        };
      }
    }

    // Build location if available
    const currentLocation: TrackingLocation | null = 
      tracking.current_location_latitude && tracking.current_location_longitude
        ? {
            latitude: tracking.current_location_latitude,
            longitude: tracking.current_location_longitude,
            label: tracking.current_location_label || undefined,
          }
        : null;

    return {
      orderId,
      currentStatus,
      statusHistory,
      serviceProvider,
      currentLocation,
      estimatedCompletionTime: tracking.estimated_completion_time?.toISOString() || null,
      lastUpdatedAt: tracking.last_updated_at.toISOString(),
    };
  }

  /**
   * Validate status transition
   */
  private validateStatusTransition(currentStatus: OrderStatus, newStatus: OrderStatus): void {
    // Can always cancel
    if (newStatus === OrderStatus.CANCELLED) {
      return;
    }

    // Can't change cancelled status
    if (currentStatus === OrderStatus.CANCELLED) {
      throw new ValidationError('Cannot change status of cancelled order');
    }

    // Valid transitions
    const validTransitions: Record<OrderStatus, OrderStatus[]> = {
      [OrderStatus.PENDING]: [OrderStatus.ASSIGNED, OrderStatus.CANCELLED],
      [OrderStatus.ASSIGNED]: [OrderStatus.IN_PROGRESS, OrderStatus.CANCELLED],
      [OrderStatus.IN_PROGRESS]: [OrderStatus.COMPLETED, OrderStatus.CANCELLED],
      [OrderStatus.COMPLETED]: [], // Can't change completed
      [OrderStatus.CANCELLED]: [], // Can't change cancelled
    };

    const allowedStatuses = validTransitions[currentStatus];
    if (!allowedStatuses.includes(newStatus)) {
      throw new ValidationError(
        `Invalid status transition from ${currentStatus} to ${newStatus}`
      );
    }
  }

  /**
   * Check if user is service provider for order
   */
  private async isServiceProviderForOrder(orderId: string, userId: string): Promise<boolean> {
    const result = await pool.query(
      'SELECT service_provider_id FROM order_tracking WHERE order_id = $1',
      [orderId]
    );

    if (result.rows.length === 0) {
      return false;
    }

    return result.rows[0].service_provider_id === userId;
  }
}

export const trackingService = new TrackingService();
