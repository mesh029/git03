import pool from '../config/database';
import { OrderStatus, OrderType } from '../models/Order';
import { PropertyType } from '../models/Property';
import { SubscriptionStatus, SubscriptionTier } from '../models/Subscription';
import { NotFoundError } from '../utils/errors';

interface UserStats {
  total: number;
  regular: number;
  agents: number;
  admins: number;
}

interface OrderStats {
  total: number;
  pending: number;
  cancelled: number;
  byType: {
    cleaning: number;
    laundry: number;
    property_booking: number;
  };
}

interface PropertyStats {
  total: number;
  available: number;
  unavailable: number;
  byType: {
    apartment: number;
    bnb: number;
  };
}

interface PlatformStats {
  users: UserStats;
  orders: OrderStats;
  properties: PropertyStats;
}

export class AdminService {
  /**
   * Get all users with filters
   */
  async getUsers(filters: {
    role?: 'regular' | 'agent' | 'admin';
    limit?: number;
    offset?: number;
  } = {}): Promise<{
    users: Array<{
      id: string;
      email: string;
      name: string;
      phone: string;
      isAdmin: boolean;
      isAgent: boolean;
      createdAt: string;
    }>;
    total: number;
    limit: number;
    offset: number;
  }> {
    const limit = Math.min(filters.limit || 20, 100);
    const offset = filters.offset || 0;

    let query = 'SELECT id, email, name, phone, is_admin, is_agent, created_at FROM users WHERE 1=1';
    const params: unknown[] = [];
    let paramIndex = 1;

    if (filters.role) {
      if (filters.role === 'admin') {
        query += ` AND is_admin = true`;
      } else if (filters.role === 'agent') {
        query += ` AND is_agent = true AND is_admin = false`;
      } else if (filters.role === 'regular') {
        query += ` AND is_agent = false AND is_admin = false`;
      }
    }

    // Get total count
    const countQuery = query.replace('SELECT id, email, name, phone, is_admin, is_agent, created_at', 'SELECT COUNT(*) as total');
    const countResult = await pool.query(countQuery, params);
    const total = parseInt(countResult.rows[0].total, 10);

    // Get paginated results
    query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const users = result.rows.map((row) => ({
      id: row.id,
      email: row.email,
      name: row.name,
      phone: row.phone,
      isAdmin: row.is_admin,
      isAgent: row.is_agent,
      createdAt: row.created_at.toISOString(),
    }));

    return {
      users,
      total,
      limit,
      offset,
    };
  }

  /**
   * Get user by ID with details
   */
  async getUserById(userId: string): Promise<{
    id: string;
    email: string;
    name: string;
    phone: string;
    isAdmin: boolean;
    isAgent: boolean;
    createdAt: string;
    orderCount: number;
    propertyCount: number;
  }> {
    // Get user
    const userResult = await pool.query(
      'SELECT id, email, name, phone, is_admin, is_agent, created_at FROM users WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      throw new NotFoundError('User');
    }

    const user = userResult.rows[0];

    // Get order count
    const orderCountResult = await pool.query(
      'SELECT COUNT(*) as count FROM orders WHERE owner_id = $1',
      [userId]
    );
    const orderCount = parseInt(orderCountResult.rows[0].count, 10);

    // Get property count (if agent)
    let propertyCount = 0;
    if (user.is_agent) {
      const propertyCountResult = await pool.query(
        'SELECT COUNT(*) as count FROM properties WHERE agent_id = $1',
        [userId]
      );
      propertyCount = parseInt(propertyCountResult.rows[0].count, 10);
    }

    return {
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      isAdmin: user.is_admin,
      isAgent: user.is_agent,
      createdAt: user.created_at.toISOString(),
      orderCount,
      propertyCount,
    };
  }

  /**
   * Update user role
   */
  async updateUserRole(
    userId: string,
    updates: {
      isAdmin?: boolean;
      isAgent?: boolean;
    }
  ): Promise<void> {
    // Check user exists
    const userResult = await pool.query('SELECT id FROM users WHERE id = $1', [userId]);
    if (userResult.rows.length === 0) {
      throw new NotFoundError('User');
    }

    const updatesList: string[] = [];
    const params: unknown[] = [];
    let paramIndex = 1;

    if (updates.isAdmin !== undefined) {
      updatesList.push(`is_admin = $${paramIndex}`);
      params.push(updates.isAdmin);
      paramIndex++;
    }

    if (updates.isAgent !== undefined) {
      updatesList.push(`is_agent = $${paramIndex}`);
      params.push(updates.isAgent);
      paramIndex++;
    }

    if (updatesList.length === 0) {
      return; // No updates
    }

    updatesList.push(`updated_at = NOW()`);
    params.push(userId);

    await pool.query(
      `UPDATE users SET ${updatesList.join(', ')} WHERE id = $${paramIndex}`,
      params
    );
  }

  /**
   * Get all orders with filters
   */
  async getAllOrders(filters: {
    status?: OrderStatus;
    type?: OrderType;
    userId?: string;
    limit?: number;
    offset?: number;
  } = {}): Promise<{
    orders: Array<{
      id: string;
      ownerId: string;
      ownerEmail: string;
      type: OrderType;
      status: OrderStatus;
      location: {
        latitude: number;
        longitude: number;
        label: string;
      };
      createdAt: string;
    }>;
    total: number;
    limit: number;
    offset: number;
  }> {
    const limit = Math.min(filters.limit || 20, 100);
    const offset = filters.offset || 0;

    let query = `
      SELECT o.id, o.owner_id, u.email as owner_email, o.type, o.status,
             o.location_latitude, o.location_longitude, o.location_label, o.created_at
      FROM orders o
      JOIN users u ON o.owner_id = u.id
      WHERE 1=1
    `;
    const params: unknown[] = [];
    let paramIndex = 1;

    if (filters.status) {
      query += ` AND o.status = $${paramIndex}`;
      params.push(filters.status);
      paramIndex++;
    }

    if (filters.type) {
      query += ` AND o.type = $${paramIndex}`;
      params.push(filters.type);
      paramIndex++;
    }

    if (filters.userId) {
      query += ` AND o.owner_id = $${paramIndex}`;
      params.push(filters.userId);
      paramIndex++;
    }

    // Get total count
    const countQuery = query.replace(
      'SELECT o.id, o.owner_id, u.email as owner_email, o.type, o.status, o.location_latitude, o.location_longitude, o.location_label, o.created_at',
      'SELECT COUNT(*) as total'
    );
    const countResult = await pool.query(countQuery, params);
    const total = parseInt(countResult.rows[0].total, 10);

    // Get paginated results
    query += ` ORDER BY o.created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const orders = result.rows.map((row) => ({
      id: row.id,
      ownerId: row.owner_id,
      ownerEmail: row.owner_email,
      type: row.type as OrderType,
      status: row.status as OrderStatus,
      location: {
        latitude: row.location_latitude,
        longitude: row.location_longitude,
        label: row.location_label,
      },
      createdAt: row.created_at.toISOString(),
    }));

    return {
      orders,
      total,
      limit,
      offset,
    };
  }

  /**
   * Update order status (admin override)
   */
  async updateOrderStatus(
    orderId: string,
    status: OrderStatus
  ): Promise<void> {
    // Check order exists
    const orderResult = await pool.query('SELECT id FROM orders WHERE id = $1', [orderId]);
    if (orderResult.rows.length === 0) {
      throw new NotFoundError('Order');
    }

    await pool.query(
      `UPDATE orders SET status = $1, updated_at = NOW(), cancelled_at = $2
       WHERE id = $3`,
      [status, status === OrderStatus.CANCELLED ? new Date() : null, orderId]
    );
  }

  /**
   * Get all properties with filters
   */
  async getAllProperties(filters: {
    isAvailable?: boolean;
    type?: PropertyType;
    agentId?: string;
    limit?: number;
    offset?: number;
  } = {}): Promise<{
    properties: Array<{
      id: string;
      agentId: string;
      agentEmail: string;
      type: PropertyType;
      title: string;
      isAvailable: boolean;
      createdAt: string;
    }>;
    total: number;
    limit: number;
    offset: number;
  }> {
    const limit = Math.min(filters.limit || 20, 100);
    const offset = filters.offset || 0;

    let query = `
      SELECT p.id, p.agent_id, u.email as agent_email, p.type, p.title,
             p.is_available, p.created_at
      FROM properties p
      JOIN users u ON p.agent_id = u.id
      WHERE 1=1
    `;
    const params: unknown[] = [];
    let paramIndex = 1;

    if (filters.isAvailable !== undefined) {
      query += ` AND p.is_available = $${paramIndex}`;
      params.push(filters.isAvailable);
      paramIndex++;
    }

    if (filters.type) {
      query += ` AND p.type = $${paramIndex}`;
      params.push(filters.type);
      paramIndex++;
    }

    if (filters.agentId) {
      query += ` AND p.agent_id = $${paramIndex}`;
      params.push(filters.agentId);
      paramIndex++;
    }

    // Get total count
    const countQuery = query.replace(
      'SELECT p.id, p.agent_id, u.email as agent_email, p.type, p.title, p.is_available, p.created_at',
      'SELECT COUNT(*) as total'
    );
    const countResult = await pool.query(countQuery, params);
    const total = parseInt(countResult.rows[0].total, 10);

    // Get paginated results
    query += ` ORDER BY p.created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const properties = result.rows.map((row) => ({
      id: row.id,
      agentId: row.agent_id,
      agentEmail: row.agent_email,
      type: row.type as PropertyType,
      title: row.title,
      isAvailable: row.is_available,
      createdAt: row.created_at.toISOString(),
    }));

    return {
      properties,
      total,
      limit,
      offset,
    };
  }

  /**
   * Get platform statistics
   */
  async getPlatformStats(): Promise<PlatformStats> {
    // User statistics
    const userStatsResult = await pool.query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE is_admin = true) as admins,
        COUNT(*) FILTER (WHERE is_agent = true AND is_admin = false) as agents,
        COUNT(*) FILTER (WHERE is_agent = false AND is_admin = false) as regular
      FROM users
    `);
    const userStats = userStatsResult.rows[0];

    // Order statistics
    const orderStatsResult = await pool.query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'pending') as pending,
        COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled,
        COUNT(*) FILTER (WHERE type = 'cleaning') as cleaning,
        COUNT(*) FILTER (WHERE type = 'laundry') as laundry,
        COUNT(*) FILTER (WHERE type = 'property_booking') as property_booking
      FROM orders
    `);
    const orderStats = orderStatsResult.rows[0];

    // Property statistics
    const propertyStatsResult = await pool.query(`
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE is_available = true) as available,
        COUNT(*) FILTER (WHERE is_available = false) as unavailable,
        COUNT(*) FILTER (WHERE type = 'apartment') as apartment,
        COUNT(*) FILTER (WHERE type = 'bnb') as bnb
      FROM properties
    `);
    const propertyStats = propertyStatsResult.rows[0];

    return {
      users: {
        total: parseInt(userStats.total, 10),
        regular: parseInt(userStats.regular, 10),
        agents: parseInt(userStats.agents, 10),
        admins: parseInt(userStats.admins, 10),
      },
      orders: {
        total: parseInt(orderStats.total, 10),
        pending: parseInt(orderStats.pending, 10),
        cancelled: parseInt(orderStats.cancelled, 10),
        byType: {
          cleaning: parseInt(orderStats.cleaning, 10),
          laundry: parseInt(orderStats.laundry, 10),
          property_booking: parseInt(orderStats.property_booking, 10),
        },
      },
      properties: {
        total: parseInt(propertyStats.total, 10),
        available: parseInt(propertyStats.available, 10),
        unavailable: parseInt(propertyStats.unavailable, 10),
        byType: {
          apartment: parseInt(propertyStats.apartment, 10),
          bnb: parseInt(propertyStats.bnb, 10),
        },
      },
    };
  }

  /**
   * Get all subscriptions with filters
   */
  async getSubscriptions(filters: {
    status?: SubscriptionStatus;
    tier?: SubscriptionTier;
    userId?: string;
    limit?: number;
    offset?: number;
  } = {}): Promise<{
    subscriptions: Array<{
      id: string;
      userId: string;
      tier: SubscriptionTier;
      status: SubscriptionStatus;
      billingPeriod: string;
      autoRenew: boolean;
      currentPeriodStart: string;
      currentPeriodEnd: string;
      cancelledAt: string | null;
      createdAt: string;
    }>;
    total: number;
    limit: number;
    offset: number;
  }> {
    const limit = Math.min(filters.limit || 20, 100);
    const offset = filters.offset || 0;

    let query = `
      SELECT id, user_id, tier, status, billing_period, auto_renew,
             current_period_start, current_period_end, cancelled_at, created_at
      FROM subscriptions
      WHERE 1=1
    `;
    const params: unknown[] = [];
    let paramIndex = 1;

    if (filters.status) {
      query += ` AND status = $${paramIndex}`;
      params.push(filters.status);
      paramIndex++;
    }

    if (filters.tier) {
      query += ` AND tier = $${paramIndex}`;
      params.push(filters.tier);
      paramIndex++;
    }

    if (filters.userId) {
      query += ` AND user_id = $${paramIndex}`;
      params.push(filters.userId);
      paramIndex++;
    }

    // Get total count
    const countQuery = query.replace(
      'SELECT id, user_id, tier, status, billing_period, auto_renew, current_period_start, current_period_end, cancelled_at, created_at',
      'SELECT COUNT(*) as total'
    );
    const countResult = await pool.query(countQuery, params);
    const total = parseInt(countResult.rows[0].total, 10);

    // Get paginated results
    query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const subscriptions = result.rows.map((row) => ({
      id: row.id,
      userId: row.user_id,
      tier: row.tier,
      status: row.status,
      billingPeriod: row.billing_period,
      autoRenew: row.auto_renew,
      currentPeriodStart: row.current_period_start.toISOString(),
      currentPeriodEnd: row.current_period_end.toISOString(),
      cancelledAt: row.cancelled_at?.toISOString() || null,
      createdAt: row.created_at.toISOString(),
    }));

    return {
      subscriptions,
      total,
      limit,
      offset,
    };
  }

  /**
   * Get subscription by ID
   */
  async getSubscriptionById(subscriptionId: string): Promise<{
    id: string;
    userId: string;
    tier: SubscriptionTier;
    status: SubscriptionStatus;
    billingPeriod: string;
    autoRenew: boolean;
    trialEndsAt: string | null;
    currentPeriodStart: string;
    currentPeriodEnd: string;
    cancelledAt: string | null;
    createdAt: string;
    updatedAt: string;
    user: {
      id: string;
      email: string;
      name: string;
    };
  }> {
    const result = await pool.query(
      `SELECT s.*, u.id as user_id_full, u.email, u.name
       FROM subscriptions s
       JOIN users u ON s.user_id = u.id
       WHERE s.id = $1`,
      [subscriptionId]
    );

    if (result.rows.length === 0) {
      throw new NotFoundError('Subscription');
    }

    const row = result.rows[0];
    return {
      id: row.id,
      userId: row.user_id,
      tier: row.tier,
      status: row.status,
      billingPeriod: row.billing_period,
      autoRenew: row.auto_renew,
      trialEndsAt: row.trial_ends_at?.toISOString() || null,
      currentPeriodStart: row.current_period_start.toISOString(),
      currentPeriodEnd: row.current_period_end.toISOString(),
      cancelledAt: row.cancelled_at?.toISOString() || null,
      createdAt: row.created_at.toISOString(),
      updatedAt: row.updated_at.toISOString(),
      user: {
        id: row.user_id_full,
        email: row.email,
        name: row.name,
      },
    };
  }

  /**
   * Update subscription status (admin override)
   */
  async updateSubscriptionStatus(
    subscriptionId: string,
    status: SubscriptionStatus
  ): Promise<void> {
    // Check subscription exists
    const checkResult = await pool.query(
      'SELECT id FROM subscriptions WHERE id = $1',
      [subscriptionId]
    );

    if (checkResult.rows.length === 0) {
      throw new NotFoundError('Subscription');
    }

    // Update status
    await pool.query(
      `UPDATE subscriptions 
       SET status = $1, updated_at = NOW()
       ${status === SubscriptionStatus.CANCELLED ? ', cancelled_at = NOW()' : ''}
       WHERE id = $2`,
      [status, subscriptionId]
    );
  }
}

export const adminService = new AdminService();
