import request from 'supertest';
import { getTestApp, initializeTestApp, setupTestDatabase, cleanupTestDatabase, closeTestConnections } from '../setup';
import { createTestUser, createTestOrder, createTestProperty } from '../helpers';

describe('Admin API Integration Tests', () => {
  let app: any;
  let pool: any;
  let admin: any;
  let adminToken: string;

  beforeAll(async () => {
    await initializeTestApp();
    app = getTestApp();
    pool = await setupTestDatabase();
  });

  beforeEach(async () => {
    await cleanupTestDatabase();

    // Create admin user
    admin = await createTestUser(pool, {
      email: 'admin@juax.test',
      password: 'Test123!@#',
      name: 'Admin User',
      is_admin: true,
    });

    const loginResponse = await request(app)
      .post('/v1/auth/login')
      .send({
        email: 'admin@juax.test',
        password: 'Test123!@#',
      });

    if (loginResponse.status !== 200 || !loginResponse.body.success) {
      console.error('Login failed:', loginResponse.status, loginResponse.body);
      throw new Error(`Login failed: ${JSON.stringify(loginResponse.body)}`);
    }

    adminToken = loginResponse.body.data.tokens.accessToken;
  });

  afterAll(async () => {
    await closeTestConnections();
  });

  describe('GET /v1/admin/users', () => {
    beforeEach(async () => {
      await createTestUser(pool, { email: 'user1@juax.test', name: 'User 1' });
      await createTestUser(pool, { email: 'user2@juax.test', name: 'User 2', is_agent: true });
      await createTestUser(pool, { email: 'user3@juax.test', name: 'User 3' });
    });

    it('should list all users', async () => {
      const response = await request(app)
        .get('/v1/admin/users')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.users.length).toBeGreaterThanOrEqual(3);
    });

    it('should filter users by role', async () => {
      const response = await request(app)
        .get('/v1/admin/users?role=agent')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.users.length).toBeGreaterThan(0);
      response.body.data.users.forEach((user: any) => {
        expect(user.isAgent).toBe(true);
        expect(user.isAdmin).toBe(false);
      });
    });

    it('should fail for non-admin user', async () => {
      const regularUser = await createTestUser(pool, {
        email: 'user@juax.test',
        password: 'Test123!@#',
        name: 'Regular User',
      });

      const loginResponse = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'user@juax.test',
          password: 'Test123!@#',
        });

      const userToken = loginResponse.body.data.tokens.accessToken;

      const response = await request(app)
        .get('/v1/admin/users')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(403);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /v1/admin/users/:id', () => {
    let user: any;

    beforeEach(async () => {
      user = await createTestUser(pool, {
        email: 'user@juax.test',
        name: 'Test User',
      });
    });

    it('should get user details', async () => {
      const response = await request(app)
        .get(`/v1/admin/users/${user.id}`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(user.id);
      expect(response.body.data.email).toBe('user@juax.test');
    });

    it('should fail with non-existent user', async () => {
      const response = await request(app)
        .get('/v1/admin/users/00000000-0000-0000-0000-000000000000')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
    });
  });

  describe('PATCH /v1/admin/users/:id/role', () => {
    let user: any;

    beforeEach(async () => {
      user = await createTestUser(pool, {
        email: 'user@juax.test',
        name: 'Test User',
        is_agent: false,
        is_admin: false,
      });
    });

    it('should update user role to agent', async () => {
      const response = await request(app)
        .patch(`/v1/admin/users/${user.id}/role`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          isAgent: true,
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('updated successfully');

      // Verify the role was actually updated by fetching the user
      const getUserResponse = await request(app)
        .get(`/v1/admin/users/${user.id}`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(getUserResponse.body.data.isAgent).toBe(true);
    });

    it('should update user role to admin', async () => {
      const response = await request(app)
        .patch(`/v1/admin/users/${user.id}/role`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          isAdmin: true,
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('updated successfully');

      // Verify the role was actually updated by fetching the user
      const getUserResponse = await request(app)
        .get(`/v1/admin/users/${user.id}`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(getUserResponse.body.data.isAdmin).toBe(true);
    });
  });

  describe('GET /v1/admin/orders', () => {
    beforeEach(async () => {
      const user1 = await createTestUser(pool, { email: 'user1@juax.test' });
      const user2 = await createTestUser(pool, { email: 'user2@juax.test' });

      await createTestOrder(pool, user1.id, { type: 'cleaning', status: 'pending' });
      await createTestOrder(pool, user2.id, { type: 'laundry', status: 'pending' });
      await createTestOrder(pool, user1.id, { type: 'cleaning', status: 'cancelled' });
    });

    it('should list all orders', async () => {
      const response = await request(app)
        .get('/v1/admin/orders')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.orders.length).toBeGreaterThanOrEqual(3);
    });

    it('should filter orders by status', async () => {
      const response = await request(app)
        .get('/v1/admin/orders?status=pending')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      response.body.data.orders.forEach((order: any) => {
        expect(order.status).toBe('pending');
      });
    });

    it('should filter orders by type', async () => {
      const response = await request(app)
        .get('/v1/admin/orders?type=cleaning')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      response.body.data.orders.forEach((order: any) => {
        expect(order.type).toBe('cleaning');
      });
    });
  });

  describe('PATCH /v1/admin/orders/:id/status', () => {
    let user: any;
    let order: any;

    beforeEach(async () => {
      user = await createTestUser(pool, { email: 'user@juax.test' });
      order = await createTestOrder(pool, user.id, { status: 'pending' });
    });

    it('should update order status', async () => {
      const response = await request(app)
        .patch(`/v1/admin/orders/${order.id}/status`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          status: 'cancelled',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('updated successfully');

      // Verify the status was actually updated by listing orders
      const listOrdersResponse = await request(app)
        .get(`/v1/admin/orders?status=cancelled`)
        .set('Authorization', `Bearer ${adminToken}`);

      const updatedOrder = listOrdersResponse.body.data.orders.find((o: any) => o.id === order.id);
      expect(updatedOrder).toBeDefined();
      expect(updatedOrder.status).toBe('cancelled');
    });
  });

  describe('GET /v1/admin/properties', () => {
    beforeEach(async () => {
      const agent1 = await createTestUser(pool, {
        email: 'agent1@juax.test',
        is_agent: true,
      });
      const agent2 = await createTestUser(pool, {
        email: 'agent2@juax.test',
        is_agent: true,
      });

      await createTestProperty(pool, agent1.id, { is_available: true });
      await createTestProperty(pool, agent2.id, { is_available: false });
    });

    it('should list all properties including unavailable', async () => {
      const response = await request(app)
        .get('/v1/admin/properties')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.properties.length).toBeGreaterThanOrEqual(2);
    });
  });

  describe('GET /v1/admin/stats', () => {
    beforeEach(async () => {
      await createTestUser(pool, { email: 'user1@juax.test' });
      await createTestUser(pool, { email: 'user2@juax.test', is_agent: true });
      
      const user = await createTestUser(pool, { email: 'user3@juax.test' });
      await createTestOrder(pool, user.id);
      
      const agent = await createTestUser(pool, { email: 'agent@juax.test', is_agent: true });
      await createTestProperty(pool, agent.id);
    });

    it('should get platform statistics', async () => {
      const response = await request(app)
        .get('/v1/admin/stats')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.users).toBeDefined();
      expect(response.body.data.orders).toBeDefined();
      expect(response.body.data.properties).toBeDefined();
    });
  });
});
