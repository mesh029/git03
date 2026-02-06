import pool from '../config/database';
import {
  PropertyType,
  CreatePropertyInput,
  PropertyResponse,
  UpdatePropertyInput,
} from '../models/Property';
import {
  ValidationError,
  NotFoundError,
  AuthorizationError,
} from '../utils/errors';
import { mapboxService } from './mapboxService';

interface PropertyRow {
  id: string;
  agent_id: string;
  type: string;
  title: string;
  location_latitude: number;
  location_longitude: number;
  area_label: string;
  is_available: boolean;
  price_label: string | null;
  rating: number | null;
  traction: number;
  amenities: string[] | null;
  house_rules: string[] | null;
  images: string[] | null;
  created_at: Date;
  updated_at: Date;
}

export class PropertyService {
  /**
   * Convert database row to PropertyResponse
   */
  private toPropertyResponse(row: PropertyRow): PropertyResponse {
    return {
      id: row.id,
      agent_id: row.agent_id,
      type: row.type as PropertyType,
      title: row.title,
      location: {
        latitude: row.location_latitude,
        longitude: row.location_longitude,
        label: row.area_label,
      },
      is_available: row.is_available,
      price_label: row.price_label || undefined,
      rating: row.rating || undefined,
      traction: row.traction,
      amenities: row.amenities || undefined,
      house_rules: row.house_rules || undefined,
      images: row.images || undefined,
      created_at: row.created_at.toISOString(),
      updated_at: row.updated_at.toISOString(),
    };
  }

  /**
   * Validate location coordinates and Kenya bounds
   */
  private validateLocation(latitude: number, longitude: number): void {
    const validation = mapboxService.validateCoordinates(latitude, longitude);

    if (!validation.valid) {
      throw new ValidationError(validation.errors.join(', '), {
        code: 'INVALID_COORDINATES',
      });
    }

    if (!validation.inKenya) {
      throw new ValidationError('Location is outside Kenya service area', {
        code: 'OUTSIDE_SERVICE_AREA',
      });
    }
  }

  /**
   * Check if property has active bookings
   */
  private async hasActiveBookings(propertyId: string): Promise<boolean> {
    const result = await pool.query(
      `SELECT COUNT(*) as count
       FROM property_bookings pb
       JOIN orders o ON pb.order_id = o.id
       WHERE pb.property_id = $1 AND o.status = 'pending'`,
      [propertyId]
    );

    return parseInt(result.rows[0].count, 10) > 0;
  }

  /**
   * Create a new property listing
   */
  async createProperty(
    input: CreatePropertyInput,
    agentId: string
  ): Promise<PropertyResponse> {
    // Validate location
    this.validateLocation(input.location_latitude, input.location_longitude);

    // Validate arrays
    if (input.amenities && input.amenities.length > 20) {
      throw new ValidationError('Maximum 20 amenities allowed', {
        field: 'amenities',
      });
    }

    if (input.house_rules && input.house_rules.length > 30) {
      throw new ValidationError('Maximum 30 house rules allowed', {
        field: 'house_rules',
      });
    }

    if (input.images && input.images.length > 20) {
      throw new ValidationError('Maximum 20 images allowed', {
        field: 'images',
      });
    }

    const result = await pool.query(
      `INSERT INTO properties (
        agent_id, type, title, location_latitude, location_longitude,
        area_label, is_available, price_label, amenities, house_rules, images
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *`,
      [
        agentId,
        input.type,
        input.title,
        input.location_latitude,
        input.location_longitude,
        input.area_label,
        true, // Default to available
        input.price_label || null,
        input.amenities || null,
        input.house_rules || null,
        input.images || null,
      ]
    );

    return this.toPropertyResponse(result.rows[0] as PropertyRow);
  }

  /**
   * Get properties with filters and pagination
   */
  async getProperties(filters: {
    isAvailable?: boolean;
    type?: PropertyType;
    agentId?: string;
    areaLabel?: string;
    limit?: number;
    offset?: number;
  } = {}): Promise<{
    properties: PropertyResponse[];
    total: number;
    limit: number;
    offset: number;
  }> {
    const limit = Math.min(filters.limit || 20, 100);
    const offset = filters.offset || 0;

    // Build query
    let query = 'SELECT * FROM properties WHERE 1=1';
    const params: unknown[] = [];
    let paramIndex = 1;

    if (filters.isAvailable !== undefined) {
      query += ` AND is_available = $${paramIndex}`;
      params.push(filters.isAvailable);
      paramIndex++;
    }

    if (filters.type) {
      query += ` AND type = $${paramIndex}`;
      params.push(filters.type);
      paramIndex++;
    }

    if (filters.agentId) {
      query += ` AND agent_id = $${paramIndex}`;
      params.push(filters.agentId);
      paramIndex++;
    }

    if (filters.areaLabel) {
      query += ` AND area_label ILIKE $${paramIndex}`;
      params.push(`%${filters.areaLabel}%`);
      paramIndex++;
    }

    // Get total count
    const countQuery = query.replace('SELECT *', 'SELECT COUNT(*) as total');
    const countResult = await pool.query(countQuery, params);
    const total = parseInt(countResult.rows[0].total, 10);

    // Get paginated results
    query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const properties = result.rows.map((row: PropertyRow) =>
      this.toPropertyResponse(row)
    );

    return {
      properties,
      total,
      limit,
      offset,
    };
  }

  /**
   * Get single property by ID
   */
  async getPropertyById(propertyId: string): Promise<PropertyResponse> {
    const result = await pool.query(
      'SELECT * FROM properties WHERE id = $1',
      [propertyId]
    );

    if (result.rows.length === 0) {
      throw new NotFoundError('Property');
    }

    return this.toPropertyResponse(result.rows[0] as PropertyRow);
  }

  /**
   * Update property (agent owner or admin)
   */
  async updateProperty(
    propertyId: string,
    input: UpdatePropertyInput,
    userId: string,
    isAdmin: boolean
  ): Promise<PropertyResponse> {
    // Get property to check ownership
    const propertyResult = await pool.query(
      'SELECT * FROM properties WHERE id = $1',
      [propertyId]
    );

    if (propertyResult.rows.length === 0) {
      throw new NotFoundError('Property');
    }

    const property = propertyResult.rows[0] as PropertyRow;

    // Check authorization
    if (!isAdmin && property.agent_id !== userId) {
      throw new AuthorizationError('Access denied');
    }

    // Validate location if provided
    if (input.location_latitude !== undefined && input.location_longitude !== undefined) {
      this.validateLocation(input.location_latitude, input.location_longitude);
    }

    // Build update query dynamically
    const updates: string[] = [];
    const params: unknown[] = [];
    let paramIndex = 1;

    if (input.title !== undefined) {
      updates.push(`title = $${paramIndex}`);
      params.push(input.title);
      paramIndex++;
    }

    if (input.location_latitude !== undefined) {
      updates.push(`location_latitude = $${paramIndex}`);
      params.push(input.location_latitude);
      paramIndex++;
    }

    if (input.location_longitude !== undefined) {
      updates.push(`location_longitude = $${paramIndex}`);
      params.push(input.location_longitude);
      paramIndex++;
    }

    if (input.area_label !== undefined) {
      updates.push(`area_label = $${paramIndex}`);
      params.push(input.area_label);
      paramIndex++;
    }

    if (input.price_label !== undefined) {
      updates.push(`price_label = $${paramIndex}`);
      params.push(input.price_label || null);
      paramIndex++;
    }

    if (input.amenities !== undefined) {
      updates.push(`amenities = $${paramIndex}`);
      params.push(input.amenities || null);
      paramIndex++;
    }

    if (input.house_rules !== undefined) {
      updates.push(`house_rules = $${paramIndex}`);
      params.push(input.house_rules || null);
      paramIndex++;
    }

    if (input.images !== undefined) {
      updates.push(`images = $${paramIndex}`);
      params.push(input.images || null);
      paramIndex++;
    }

    if (updates.length === 0) {
      // No updates provided
      return this.toPropertyResponse(property);
    }

    // Add updated_at
    updates.push(`updated_at = NOW()`);

    // Add property ID to params
    params.push(propertyId);

    const updateQuery = `UPDATE properties SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`;

    const updateResult = await pool.query(updateQuery, params);

    return this.toPropertyResponse(updateResult.rows[0] as PropertyRow);
  }

  /**
   * Delete property (agent owner or admin)
   */
  async deleteProperty(
    propertyId: string,
    userId: string,
    isAdmin: boolean
  ): Promise<void> {
    // Get property to check ownership
    const propertyResult = await pool.query(
      'SELECT * FROM properties WHERE id = $1',
      [propertyId]
    );

    if (propertyResult.rows.length === 0) {
      throw new NotFoundError('Property');
    }

    const property = propertyResult.rows[0] as PropertyRow;

    // Check authorization
    if (!isAdmin && property.agent_id !== userId) {
      throw new AuthorizationError('Access denied');
    }

    // Check for active bookings
    const hasBookings = await this.hasActiveBookings(propertyId);
    if (hasBookings) {
      throw new ValidationError(
        'Cannot delete property with active bookings',
        {
          code: 'PROPERTY_HAS_BOOKINGS',
        }
      );
    }

    // Delete property (CASCADE will handle property_bookings)
    await pool.query('DELETE FROM properties WHERE id = $1', [propertyId]);
  }

  /**
   * Toggle property availability (agent owner or admin)
   */
  async toggleAvailability(
    propertyId: string,
    userId: string,
    isAdmin: boolean
  ): Promise<PropertyResponse> {
    // Get property to check ownership
    const propertyResult = await pool.query(
      'SELECT * FROM properties WHERE id = $1',
      [propertyId]
    );

    if (propertyResult.rows.length === 0) {
      throw new NotFoundError('Property');
    }

    const property = propertyResult.rows[0] as PropertyRow;

    // Check authorization
    if (!isAdmin && property.agent_id !== userId) {
      throw new AuthorizationError('Access denied');
    }

    // Toggle availability
    const newAvailability = !property.is_available;

    // If making unavailable, check for active bookings
    if (!newAvailability) {
      const hasBookings = await this.hasActiveBookings(propertyId);
      if (hasBookings) {
        throw new ValidationError(
          'Cannot make property unavailable with active bookings',
          {
            code: 'PROPERTY_HAS_BOOKINGS',
          }
        );
      }
    }

    const updateResult = await pool.query(
      `UPDATE properties
       SET is_available = $1, updated_at = NOW()
       WHERE id = $2
       RETURNING *`,
      [newAvailability, propertyId]
    );

    return this.toPropertyResponse(updateResult.rows[0] as PropertyRow);
  }
}

export const propertyService = new PropertyService();
