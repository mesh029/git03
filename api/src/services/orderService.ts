import { v4 as uuidv4 } from 'uuid';
import pool from '../config/database';
import {
  Order,
  OrderType,
  OrderStatus,
  CreateOrderInput,
  OrderResponse,
  Location,
  CleaningDetails,
  LaundryDetails,
  PropertyBookingDetails,
} from '../models/Order';
import {
  ValidationError,
  NotFoundError,
  AuthorizationError,
} from '../utils/errors';

interface OrderRow {
  id: string;
  owner_id: string;
  type: string;
  status: string;
  location_latitude: number;
  location_longitude: number;
  location_label: string;
  details: Record<string, unknown>;
  created_at: Date;
  updated_at: Date;
  cancelled_at: Date | null;
}

export class OrderService {
  /**
   * Convert database row to OrderResponse
   */
  private toOrderResponse(row: OrderRow): OrderResponse {
    return {
      id: row.id,
      owner_id: row.owner_id,
      status: row.status as OrderStatus,
      type: row.type as OrderType,
      location: {
        latitude: row.location_latitude,
        longitude: row.location_longitude,
        label: row.location_label,
      },
      details: row.details,
      created_at: row.created_at.toISOString(),
      updated_at: row.updated_at.toISOString(),
      cancelled_at: row.cancelled_at?.toISOString(),
    };
  }

  /**
   * Validate location coordinates
   */
  private validateLocation(location: Location): void {
    if (location.latitude < -90 || location.latitude > 90) {
      throw new ValidationError('Latitude must be between -90 and 90', {
        field: 'location.latitude',
      });
    }

    if (location.longitude < -180 || location.longitude > 180) {
      throw new ValidationError('Longitude must be between -180 and 180', {
        field: 'location.longitude',
      });
    }

    if (!location.label || location.label.trim().length === 0) {
      throw new ValidationError('Location label is required', {
        field: 'location.label',
      });
    }

    if (location.label.length > 255) {
      throw new ValidationError('Location label must be 255 characters or less', {
        field: 'location.label',
      });
    }
  }

  /**
   * Validate property booking details and check availability
   */
  private async validatePropertyBooking(
    details: PropertyBookingDetails,
    userId: string
  ): Promise<void> {
    const { propertyId, checkIn, checkOut, guests } = details;

    // Validate property exists
    const propertyResult = await pool.query(
      'SELECT id, is_available FROM properties WHERE id = $1',
      [propertyId]
    );

    if (propertyResult.rows.length === 0) {
      throw new ValidationError('Property not found', {
        code: 'PROPERTY_NOT_FOUND',
      });
    }

    const property = propertyResult.rows[0];

    if (!property.is_available) {
      throw new ValidationError('Property is not available', {
        code: 'PROPERTY_NOT_AVAILABLE',
      });
    }

    // Validate dates
    const checkInDate = new Date(checkIn);
    const checkOutDate = new Date(checkOut);
    const now = new Date();

    if (checkInDate < now) {
      throw new ValidationError('Check-in date must be in the future', {
        code: 'INVALID_BOOKING_DATES',
      });
    }

    if (checkOutDate <= checkInDate) {
      throw new ValidationError('Check-out date must be after check-in date', {
        code: 'INVALID_BOOKING_DATES',
      });
    }

    // Check minimum stay (1 day)
    const daysDiff = Math.ceil(
      (checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24)
    );
    if (daysDiff < 1) {
      throw new ValidationError('Minimum stay duration is 1 day', {
        code: 'INVALID_BOOKING_DATES',
      });
    }

    // Check maximum stay (365 days)
    if (daysDiff > 365) {
      throw new ValidationError('Maximum stay duration is 365 days', {
        code: 'INVALID_BOOKING_DATES',
      });
    }

    // Validate guests
    if (guests !== undefined) {
      if (guests < 1 || guests > 20) {
        throw new ValidationError('Guests must be between 1 and 20', {
          field: 'details.guests',
        });
      }
    }

    // Check for conflicting bookings (efficient query with index)
    const conflictResult = await pool.query(
      `SELECT id FROM property_bookings
       WHERE property_id = $1
       AND (
         (check_in <= $2 AND check_out >= $2) OR
         (check_in <= $3 AND check_out >= $3) OR
         (check_in >= $2 AND check_out <= $3)
       )
       LIMIT 1`,
      [propertyId, checkInDate, checkOutDate]
    );

    if (conflictResult.rows.length > 0) {
      throw new ValidationError('Property is not available for selected dates', {
        code: 'PROPERTY_BOOKING_CONFLICT',
      });
    }
  }

  /**
   * Create a new order
   */
  async createOrder(input: CreateOrderInput, userId: string): Promise<OrderResponse> {
    // Validate location
    this.validateLocation(input.location);

    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      // Insert order
      const orderResult = await client.query(
        `INSERT INTO orders (
          owner_id, type, status, location_latitude, location_longitude,
          location_label, details
        ) VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id, owner_id, type, status, location_latitude, location_longitude,
          location_label, details, created_at, updated_at, cancelled_at`,
        [
          userId,
          input.type,
          OrderStatus.PENDING,
          input.location.latitude,
          input.location.longitude,
          input.location.label,
          JSON.stringify(input.details),
        ]
      );

      const order = orderResult.rows[0] as OrderRow;

      // Handle property booking
      if (input.type === OrderType.PROPERTY_BOOKING) {
        const bookingDetails = input.details as PropertyBookingDetails;

        // Validate property booking
        await this.validatePropertyBooking(bookingDetails, userId);

        // Insert property booking
        await client.query(
          `INSERT INTO property_bookings (order_id, property_id, check_in, check_out, guests)
           VALUES ($1, $2, $3, $4, $5)`,
          [
            order.id,
            bookingDetails.propertyId,
            new Date(bookingDetails.checkIn),
            new Date(bookingDetails.checkOut),
            bookingDetails.guests || null,
          ]
        );
      }

      await client.query('COMMIT');

      return this.toOrderResponse(order);
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Get orders for a user with efficient pagination
   */
  async getUserOrders(
    userId: string,
    filters: {
      status?: OrderStatus;
      type?: OrderType;
      limit?: number;
      offset?: number;
    } = {}
  ): Promise<{ orders: OrderResponse[]; total: number; limit: number; offset: number }> {
    const limit = Math.min(filters.limit || 20, 100);
    const offset = filters.offset || 0;

    // Build query efficiently with single query for count and data
    let query = 'SELECT * FROM orders WHERE owner_id = $1';
    const params: unknown[] = [userId];
    let paramIndex = 2;

    if (filters.status) {
      query += ` AND status = $${paramIndex}`;
      params.push(filters.status);
      paramIndex++;
    }

    if (filters.type) {
      query += ` AND type = $${paramIndex}`;
      params.push(filters.type);
      paramIndex++;
    }

    // Get total count (optimized with COUNT)
    const countQuery = query.replace('SELECT *', 'SELECT COUNT(*) as total');
    const countResult = await pool.query(countQuery, params);
    const total = parseInt(countResult.rows[0].total, 10);

    // Get paginated results
    query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const orders = result.rows.map((row: OrderRow) => this.toOrderResponse(row));

    return {
      orders,
      total,
      limit,
      offset,
    };
  }

  /**
   * Get single order by ID (with ownership check)
   */
  async getOrderById(orderId: string, userId: string): Promise<OrderResponse> {
    const result = await pool.query(
      'SELECT * FROM orders WHERE id = $1',
      [orderId]
    );

    if (result.rows.length === 0) {
      throw new NotFoundError('Order');
    }

    const order = result.rows[0] as OrderRow;

    // Check ownership
    if (order.owner_id !== userId) {
      throw new AuthorizationError('Access denied');
    }

    return this.toOrderResponse(order);
  }

  /**
   * Cancel an order (idempotent)
   */
  async cancelOrder(orderId: string, userId: string): Promise<OrderResponse> {
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      // Get order with row lock to prevent race conditions
      const orderResult = await client.query(
        `SELECT * FROM orders WHERE id = $1 FOR UPDATE`,
        [orderId]
      );

      if (orderResult.rows.length === 0) {
        throw new NotFoundError('Order');
      }

      const order = orderResult.rows[0] as OrderRow;

      // Check ownership
      if (order.owner_id !== userId) {
        throw new AuthorizationError('Access denied');
      }

      // Check if already cancelled (idempotent)
      if (order.status === OrderStatus.CANCELLED) {
        await client.query('COMMIT');
        return this.toOrderResponse(order);
      }

      // Check if can be cancelled
      if (order.status !== OrderStatus.PENDING) {
        throw new ValidationError('Only pending orders can be cancelled', {
          code: 'ORDER_ALREADY_CANCELLED',
        });
      }

      // Update order status
      const updateResult = await client.query(
        `UPDATE orders
         SET status = $1, cancelled_at = NOW(), updated_at = NOW()
         WHERE id = $2
         RETURNING *`,
        [OrderStatus.CANCELLED, orderId]
      );

      const updatedOrder = updateResult.rows[0] as OrderRow;

      // Delete property booking if exists
      if (order.type === OrderType.PROPERTY_BOOKING) {
        await client.query(
          'DELETE FROM property_bookings WHERE order_id = $1',
          [orderId]
        );
      }

      await client.query('COMMIT');

      return this.toOrderResponse(updatedOrder);
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
}

export const orderService = new OrderService();
