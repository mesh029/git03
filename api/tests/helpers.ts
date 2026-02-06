import { Pool } from 'pg';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { config } from '../src/config/env';

export interface TestUser {
  id: string;
  email: string;
  password: string;
  name: string;
  phone?: string;
  is_admin?: boolean;
  is_agent?: boolean;
}

/**
 * Create a test user in the database
 */
export async function createTestUser(
  pool: Pool,
  user: Partial<TestUser> = {}
): Promise<TestUser> {
  const defaultUser: TestUser = {
    id: '',
    email: `test-${Date.now()}@example.com`,
    password: 'Test123!@#',
    name: 'Test User',
    phone: '+254712345678',
    is_admin: false,
    is_agent: false,
    ...user,
  };

  // Hash password
  const passwordHash = await bcrypt.hash(defaultUser.password, 12);

  const result = await pool.query(
    `INSERT INTO users (email, password_hash, name, phone, is_admin, is_agent)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, email, name, phone, is_admin, is_agent`,
    [
      defaultUser.email.toLowerCase(),
      passwordHash,
      defaultUser.name,
      defaultUser.phone || null,
      defaultUser.is_admin || false,
      defaultUser.is_agent || false,
    ]
  );

  const createdUser = result.rows[0];
  return {
    ...createdUser,
    password: defaultUser.password,
  };
}

/**
 * Generate JWT token for testing
 */
export function generateTestToken(userId: string, email: string): string {
  return jwt.sign(
    { sub: userId, email },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn }
  );
}

/**
 * Create test property
 */
export async function createTestProperty(
  pool: Pool,
  agentId: string,
  property: any = {}
): Promise<any> {
  const defaultProperty = {
    type: 'apartment',
    title: 'Test Property',
    location_latitude: -1.2634,
    location_longitude: 36.8007,
    area_label: 'Westlands',
    price_label: 'KES 15,000/night',
    rating: 4.5,
    traction: 120,
    amenities: ['WiFi', 'Parking'],
    house_rules: ['No smoking'],
    images: [],
    is_available: true,
    ...property,
  };

  const result = await pool.query(
    `INSERT INTO properties (
      agent_id, type, title, location_latitude, location_longitude,
      area_label, price_label, rating, traction,
      amenities, house_rules, images, is_available
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    RETURNING *`,
    [
      agentId,
      defaultProperty.type,
      defaultProperty.title,
      defaultProperty.location_latitude,
      defaultProperty.location_longitude,
      defaultProperty.area_label,
      defaultProperty.price_label,
      defaultProperty.rating,
      defaultProperty.traction,
      defaultProperty.amenities,
      defaultProperty.house_rules,
      defaultProperty.images,
      defaultProperty.is_available,
    ]
  );

  return result.rows[0];
}

/**
 * Create test order
 */
export async function createTestOrder(
  pool: Pool,
  userId: string,
  order: any = {}
): Promise<any> {
  const defaultOrder = {
    owner_id: userId,
    type: 'cleaning',
    location_latitude: -1.2634,
    location_longitude: 36.8007,
    location_label: 'Westlands, Nairobi',
    details: { service: 'deepCleaning', rooms: 3 },
    status: 'pending',
    ...order,
  };

  const result = await pool.query(
    `INSERT INTO orders (
      owner_id, type, location_latitude, location_longitude,
      location_label, details, status
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *`,
    [
      defaultOrder.owner_id,
      defaultOrder.type,
      defaultOrder.location_latitude,
      defaultOrder.location_longitude,
      defaultOrder.location_label,
      JSON.stringify(defaultOrder.details),
      defaultOrder.status,
    ]
  );

  return result.rows[0];
}
