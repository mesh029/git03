import pool from '../config/database';
import {
  ServiceLocationType,
  CreateServiceLocationInput,
  UpdateServiceLocationInput,
  ServiceLocationResponse,
  NearbyServiceLocationQuery,
} from '../models/ServiceLocation';
import { ValidationError, NotFoundError } from '../utils/errors';
import { mapboxService } from './mapboxService';

interface ServiceLocationRow {
  id: string;
  name: string;
  type: string;
  location_latitude: number;
  location_longitude: number;
  address: string;
  area_label: string;
  city: string;
  is_active: boolean;
  operating_hours: Record<string, unknown> | null;
  contact_phone: string | null;
  notes: string | null;
  created_at: Date;
  updated_at: Date;
}

export class ServiceLocationService {
  /**
   * Convert database row to ServiceLocationResponse
   */
  private toServiceLocationResponse(
    row: ServiceLocationRow,
    distanceKm?: number
  ): ServiceLocationResponse {
    return {
      id: row.id,
      name: row.name,
      type: row.type as ServiceLocationType,
      location: {
        latitude: row.location_latitude,
        longitude: row.location_longitude,
        address: row.address,
        area_label: row.area_label,
        city: row.city,
      },
      is_active: row.is_active,
      operating_hours: (row.operating_hours as any) || undefined,
      contact_phone: row.contact_phone || undefined,
      notes: row.notes || undefined,
      distance_km: distanceKm,
      created_at: row.created_at.toISOString(),
      updated_at: row.updated_at.toISOString(),
    };
  }

  /**
   * Validate location coordinates
   */
  private validateLocation(latitude: number, longitude: number): void {
    if (latitude < -90 || latitude > 90) {
      throw new ValidationError('Latitude must be between -90 and 90');
    }

    if (longitude < -180 || longitude > 180) {
      throw new ValidationError('Longitude must be between -180 and 180');
    }

    const validation = mapboxService.validateCoordinates(latitude, longitude);
    if (!validation.valid) {
      throw new ValidationError(validation.errors.join(', '));
    }

    if (!validation.inKenya) {
      throw new ValidationError('Location is outside Kenya service area');
    }
  }


  /**
   * Create a new service location
   */
  async createServiceLocation(
    input: CreateServiceLocationInput
  ): Promise<ServiceLocationResponse> {
    this.validateLocation(input.location_latitude, input.location_longitude);

    const result = await pool.query(
      `INSERT INTO service_locations (
        name, type, location_latitude, location_longitude,
        address, area_label, city, operating_hours,
        contact_phone, notes
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *`,
      [
        input.name,
        input.type,
        input.location_latitude,
        input.location_longitude,
        input.address,
        input.area_label,
        input.city || 'Kisumu',
        input.operating_hours ? JSON.stringify(input.operating_hours) : null,
        input.contact_phone || null,
        input.notes || null,
      ]
    );

    return this.toServiceLocationResponse(result.rows[0] as ServiceLocationRow);
  }

  /**
   * Get service location by ID
   */
  async getServiceLocationById(id: string): Promise<ServiceLocationResponse> {
    const result = await pool.query(
      'SELECT * FROM service_locations WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      throw new NotFoundError('Service location');
    }

    return this.toServiceLocationResponse(result.rows[0] as ServiceLocationRow);
  }

  /**
   * Get all service locations (with optional filters)
   */
  async getServiceLocations(filters: {
    type?: ServiceLocationType;
    city?: string;
    is_active?: boolean;
  } = {}): Promise<ServiceLocationResponse[]> {
    let query = 'SELECT * FROM service_locations WHERE 1=1';
    const params: unknown[] = [];
    let paramIndex = 1;

    if (filters.type) {
      query += ` AND type = $${paramIndex}`;
      params.push(filters.type);
      paramIndex++;
    }

    if (filters.city) {
      query += ` AND city = $${paramIndex}`;
      params.push(filters.city);
      paramIndex++;
    }

    if (filters.is_active !== undefined) {
      query += ` AND is_active = $${paramIndex}`;
      params.push(filters.is_active);
      paramIndex++;
    }

    query += ' ORDER BY name ASC';

    const result = await pool.query(query, params);

    return result.rows.map((row: ServiceLocationRow) =>
      this.toServiceLocationResponse(row)
    );
  }

  /**
   * Find nearby service locations
   */
  async findNearbyServiceLocations(
    query: NearbyServiceLocationQuery
  ): Promise<ServiceLocationResponse[]> {
    const radiusKm = query.radius_km || 10;
    const limit = query.limit || 10;

    this.validateLocation(query.latitude, query.longitude);

    const params: unknown[] = [query.latitude, query.longitude];
    let paramIndex = 3;

    // Build WHERE clause conditions
    let whereConditions = 'WHERE is_active = TRUE';
    
    if (query.type) {
      whereConditions += ` AND (type = $${paramIndex} OR type = 'both')`;
      params.push(query.type);
      paramIndex++;
    }

    // Use subquery to allow filtering by calculated distance
    // Calculate distance in inner query, filter in outer query
    const sqlQuery = `
      SELECT 
        id, name, type, location_latitude, location_longitude,
        address, area_label, city, is_active, operating_hours,
        contact_phone, notes, created_at, updated_at,
        distance_km
      FROM (
        SELECT 
          *,
          (
            6371 * acos(
              cos(radians($1)) * cos(radians(location_latitude)) *
              cos(radians(location_longitude) - radians($2)) +
              sin(radians($1)) * sin(radians(location_latitude))
            )
          ) AS distance_km
        FROM service_locations
        ${whereConditions}
      ) AS locations_with_distance
      WHERE distance_km <= $${paramIndex}
      ORDER BY distance_km ASC
      LIMIT $${paramIndex + 1}
    `;

    params.push(radiusKm, limit);

    const result = await pool.query(sqlQuery, params);

    return result.rows.map((row: ServiceLocationRow & { distance_km: number }) =>
      this.toServiceLocationResponse(row, row.distance_km)
    );
  }

  /**
   * Update service location
   */
  async updateServiceLocation(
    id: string,
    input: UpdateServiceLocationInput
  ): Promise<ServiceLocationResponse> {
    // Check if exists
    const existing = await pool.query(
      'SELECT * FROM service_locations WHERE id = $1',
      [id]
    );

    if (existing.rows.length === 0) {
      throw new NotFoundError('Service location');
    }

    // Validate location if provided
    const latitude = input.location_latitude ?? existing.rows[0].location_latitude;
    const longitude = input.location_longitude ?? existing.rows[0].location_longitude;

    if (input.location_latitude !== undefined || input.location_longitude !== undefined) {
      this.validateLocation(latitude, longitude);
    }

    // Build update query dynamically
    const updates: string[] = [];
    const params: unknown[] = [];
    let paramIndex = 1;

    if (input.name !== undefined) {
      updates.push(`name = $${paramIndex}`);
      params.push(input.name);
      paramIndex++;
    }

    if (input.type !== undefined) {
      updates.push(`type = $${paramIndex}`);
      params.push(input.type);
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

    if (input.address !== undefined) {
      updates.push(`address = $${paramIndex}`);
      params.push(input.address);
      paramIndex++;
    }

    if (input.area_label !== undefined) {
      updates.push(`area_label = $${paramIndex}`);
      params.push(input.area_label);
      paramIndex++;
    }

    if (input.city !== undefined) {
      updates.push(`city = $${paramIndex}`);
      params.push(input.city);
      paramIndex++;
    }

    if (input.is_active !== undefined) {
      updates.push(`is_active = $${paramIndex}`);
      params.push(input.is_active);
      paramIndex++;
    }

    if (input.operating_hours !== undefined) {
      updates.push(`operating_hours = $${paramIndex}`);
      params.push(JSON.stringify(input.operating_hours));
      paramIndex++;
    }

    if (input.contact_phone !== undefined) {
      updates.push(`contact_phone = $${paramIndex}`);
      params.push(input.contact_phone);
      paramIndex++;
    }

    if (input.notes !== undefined) {
      updates.push(`notes = $${paramIndex}`);
      params.push(input.notes);
      paramIndex++;
    }

    if (updates.length === 0) {
      return this.toServiceLocationResponse(existing.rows[0] as ServiceLocationRow);
    }

    updates.push(`updated_at = NOW()`);
    params.push(id);

    const result = await pool.query(
      `UPDATE service_locations
       SET ${updates.join(', ')}
       WHERE id = $${paramIndex}
       RETURNING *`,
      params
    );

    return this.toServiceLocationResponse(result.rows[0] as ServiceLocationRow);
  }

  /**
   * Delete service location (soft delete by setting is_active = false)
   */
  async deleteServiceLocation(id: string): Promise<void> {
    const result = await pool.query(
      'UPDATE service_locations SET is_active = FALSE WHERE id = $1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      throw new NotFoundError('Service location');
    }
  }
}

export const serviceLocationService = new ServiceLocationService();
