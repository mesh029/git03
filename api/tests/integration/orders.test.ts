import request from 'supertest';
import { getTestApp, initializeTestApp, setupTestDatabase, cleanupTestDatabase, closeTestConnections } from '../setup';
import { createTestUser, createTestOrder, createTestProperty } from '../helpers';

describe('Orders API Integration Tests', () => {
  let app: any;
  let pool: any;
  let user: any;
  let accessToken: string;

  beforeAll(async () => {
    await initializeTestApp();
    app = getTestApp();
    pool = await setupTestDatabase();
  });

  beforeEach(async () => {
    await cleanupTestDatabase();
    
    // Create test user and login
    user = await createTestUser(pool, {
      email: 'user1@juax.test',
      password: 'Test123!@#',
      name: 'John Doe',
    });

    const loginResponse = await request(app)
      .post('/v1/auth/login')
      .send({
        email: 'user1@juax.test',
        password: 'Test123!@#',
      });

    accessToken = loginResponse.body.data.tokens.accessToken;
  });

  afterAll(async () => {
    await closeTestConnections();
  });

  describe('POST /v1/orders', () => {
    it('should create cleaning order successfully', async () => {
      const response = await request(app)
        .post('/v1/orders')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          type: 'cleaning',
          location: {
            latitude: -1.2634,
            longitude: 36.8007,
            label: 'Westlands, Nairobi',
          },
          details: {
            service: 'deepCleaning',
            rooms: 3,
          },
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.type).toBe('cleaning');
      expect(response.body.data.status).toBe('pending');
      expect(response.body.data.location.label).toBe('Westlands, Nairobi');
    });

    it('should create laundry order successfully', async () => {
      const response = await request(app)
        .post('/v1/orders')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          type: 'laundry',
          location: {
            latitude: -0.0917,
            longitude: 34.7680,
            label: 'Milimani Road, Kisumu',
          },
          details: {
            serviceType: 'washAndFold',
            quantity: 5,
            items: ['shirts', 'pants', 'towels'],
          },
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.type).toBe('laundry');
    });

    it('should create property booking order successfully', async () => {
      // Create agent and property
      const agent = await createTestUser(pool, {
        email: 'agent@juax.test',
        password: 'Test123!@#',
        name: 'Agent User',
        is_agent: true,
      });

      const property = await createTestProperty(pool, agent.id, {
        is_available: true,
      });

      const checkIn = new Date();
      checkIn.setDate(checkIn.getDate() + 1);
      const checkOut = new Date();
      checkOut.setDate(checkOut.getDate() + 4);

      const response = await request(app)
        .post('/v1/orders')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          type: 'property_booking',
          location: {
            latitude: -1.2634,
            longitude: 36.8007,
            label: 'Westlands, Nairobi',
          },
          details: {
            propertyId: property.id,
            checkIn: checkIn.toISOString(),
            checkOut: checkOut.toISOString(),
            guests: 2,
          },
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.type).toBe('property_booking');
    });

    it('should fail with invalid location coordinates', async () => {
      const response = await request(app)
        .post('/v1/orders')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          type: 'cleaning',
          location: {
            latitude: 999, // Invalid latitude
            longitude: 36.8007,
            label: 'Invalid Location',
          },
          details: {
            service: 'deepCleaning',
            rooms: 3,
          },
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail without authentication', async () => {
      const response = await request(app)
        .post('/v1/orders')
        .send({
          type: 'cleaning',
          location: {
            latitude: -1.2634,
            longitude: 36.8007,
            label: 'Westlands, Nairobi',
          },
          details: {
            service: 'deepCleaning',
            rooms: 3,
          },
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should fail with missing location label', async () => {
      const response = await request(app)
        .post('/v1/orders')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({
          type: 'cleaning',
          location: {
            latitude: -1.2634,
            longitude: 36.8007,
            // Missing label
          },
          details: {
            service: 'deepCleaning',
            rooms: 3,
          },
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /v1/orders', () => {
    beforeEach(async () => {
      // Create multiple orders
      await createTestOrder(pool, user.id, { type: 'cleaning', status: 'pending' });
      await createTestOrder(pool, user.id, { type: 'laundry', status: 'pending' });
      await createTestOrder(pool, user.id, { type: 'cleaning', status: 'cancelled' });
    });

    it('should list all user orders', async () => {
      const response = await request(app)
        .get('/v1/orders')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.orders.length).toBeGreaterThan(0);
    });

    it('should filter orders by status', async () => {
      const response = await request(app)
        .get('/v1/orders?status=pending')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      response.body.data.orders.forEach((order: any) => {
        expect(order.status).toBe('pending');
      });
    });

    it('should filter orders by type', async () => {
      const response = await request(app)
        .get('/v1/orders?type=cleaning')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      response.body.data.orders.forEach((order: any) => {
        expect(order.type).toBe('cleaning');
      });
    });

    it('should support pagination', async () => {
      const response = await request(app)
        .get('/v1/orders?limit=1&offset=0')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.orders.length).toBeLessThanOrEqual(1);
    });

    it('should fail without authentication', async () => {
      const response = await request(app)
        .get('/v1/orders');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /v1/orders/:id', () => {
    let order: any;

    beforeEach(async () => {
      order = await createTestOrder(pool, user.id);
    });

    it('should get own order by ID', async () => {
      const response = await request(app)
        .get(`/v1/orders/${order.id}`)
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(order.id);
    });

    it('should fail to get another user\'s order', async () => {
      // Create another user
      const otherUser = await createTestUser(pool, {
        email: 'user2@juax.test',
        password: 'Test123!@#',
        name: 'Jane Smith',
      });

      const otherOrder = await createTestOrder(pool, otherUser.id);

      const response = await request(app)
        .get(`/v1/orders/${otherOrder.id}`)
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(403);
      expect(response.body.success).toBe(false);
    });

    it('should fail with non-existent order', async () => {
      const response = await request(app)
        .get('/v1/orders/00000000-0000-0000-0000-000000000000')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
    });
  });

  describe('PATCH /v1/orders/:id/cancel', () => {
    let order: any;

    beforeEach(async () => {
      order = await createTestOrder(pool, user.id, { status: 'pending' });
    });

    it('should cancel pending order', async () => {
      const response = await request(app)
        .patch(`/v1/orders/${order.id}/cancel`)
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe('cancelled');
      expect(response.body.data.cancelled_at).toBeDefined();
    });

    it('should be idempotent (cancel already cancelled order)', async () => {
      // Cancel once
      await request(app)
        .patch(`/v1/orders/${order.id}/cancel`)
        .set('Authorization', `Bearer ${accessToken}`);

      // Cancel again
      const response = await request(app)
        .patch(`/v1/orders/${order.id}/cancel`)
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.data.status).toBe('cancelled');
    });

    it('should fail to cancel another user\'s order', async () => {
      const otherUser = await createTestUser(pool, {
        email: 'user2@juax.test',
        password: 'Test123!@#',
        name: 'Jane Smith',
      });

      const otherOrder = await createTestOrder(pool, otherUser.id);

      const response = await request(app)
        .patch(`/v1/orders/${otherOrder.id}/cancel`)
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(403);
      expect(response.body.success).toBe(false);
    });

    it('should fail with non-existent order', async () => {
      const response = await request(app)
        .patch('/v1/orders/00000000-0000-0000-0000-000000000000/cancel')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
    });
  });
});
