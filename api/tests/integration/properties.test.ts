import request from 'supertest';
import { getTestApp, initializeTestApp, setupTestDatabase, cleanupTestDatabase, closeTestConnections } from '../setup';
import { createTestUser, createTestProperty } from '../helpers';

describe('Properties API Integration Tests', () => {
  let app: any;
  let pool: any;
  let agent: any;
  let admin: any;
  let agentToken: string;
  let adminToken: string;

  beforeAll(async () => {
    await initializeTestApp();
    app = getTestApp();
    pool = await setupTestDatabase();
  });

  beforeEach(async () => {
    await cleanupTestDatabase();

    // Create agent user
    agent = await createTestUser(pool, {
      email: 'agent@juax.test',
      password: 'Test123!@#',
      name: 'Agent User',
      is_agent: true,
    });

    const agentLoginResponse = await request(app)
      .post('/v1/auth/login')
      .send({
        email: 'agent@juax.test',
        password: 'Test123!@#',
      });
    agentToken = agentLoginResponse.body.data.tokens.accessToken;

    // Create admin user
    admin = await createTestUser(pool, {
      email: 'admin@juax.test',
      password: 'Test123!@#',
      name: 'Admin User',
      is_admin: true,
    });

    const adminLoginResponse = await request(app)
      .post('/v1/auth/login')
      .send({
        email: 'admin@juax.test',
        password: 'Test123!@#',
      });
    adminToken = adminLoginResponse.body.data.tokens.accessToken;
  });

  afterAll(async () => {
    await closeTestConnections();
  });

  describe('GET /v1/properties (Public)', () => {
    beforeEach(async () => {
      // Create test properties
      await createTestProperty(pool, agent.id, {
        title: 'Available Apartment',
        is_available: true,
      });
      await createTestProperty(pool, agent.id, {
        title: 'Unavailable Apartment',
        is_available: false,
      });
    });

    it('should list only available properties', async () => {
      const response = await request(app)
        .get('/v1/properties');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.properties.length).toBeGreaterThan(0);
      response.body.data.properties.forEach((property: any) => {
        expect(property.is_available).toBe(true);
      });
    });

    it('should filter properties by type', async () => {
      await createTestProperty(pool, agent.id, {
        type: 'bnb',
        is_available: true,
      });

      const response = await request(app)
        .get('/v1/properties?type=bnb');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      response.body.data.properties.forEach((property: any) => {
        expect(property.type).toBe('bnb');
      });
    });

    it('should support pagination', async () => {
      const response = await request(app)
        .get('/v1/properties?limit=1&offset=0');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.properties.length).toBeLessThanOrEqual(1);
    });
  });

  describe('GET /v1/properties/:id (Public)', () => {
    let property: any;

    beforeEach(async () => {
      property = await createTestProperty(pool, agent.id, {
        is_available: true,
      });
    });

    it('should get property details', async () => {
      const response = await request(app)
        .get(`/v1/properties/${property.id}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(property.id);
      expect(response.body.data.title).toBeDefined();
    });

    it('should fail with non-existent property', async () => {
      const response = await request(app)
        .get('/v1/properties/00000000-0000-0000-0000-000000000000');

      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /v1/properties (Agent/Admin)', () => {
    it('should create property as agent', async () => {
      const response = await request(app)
        .post('/v1/properties')
        .set('Authorization', `Bearer ${agentToken}`)
        .send({
          type: 'apartment',
          title: 'New Apartment',
          location: {
            latitude: -1.2634,
            longitude: 36.8007,
            label: 'Westlands, Nairobi',
          },
          area_label: 'Westlands',
          price_label: 'KES 15,000/night',
          rating: 4.5,
          traction: 120,
          amenities: ['WiFi', 'Parking'],
          house_rules: 'No smoking',
          images: [],
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.title).toBe('New Apartment');
      expect(response.body.data.agent_id).toBe(agent.id);
    });

    it('should create property as admin', async () => {
      const response = await request(app)
        .post('/v1/properties')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          type: 'bnb',
          title: 'Admin Created BnB',
          location: {
            latitude: -0.0917,
            longitude: 34.7680,
            label: 'Milimani Road, Kisumu',
          },
          area_label: 'Milimani',
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
    });

    it('should fail for regular user', async () => {
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
        .post('/v1/properties')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          type: 'apartment',
          title: 'Unauthorized Property',
          location: {
            latitude: -1.2634,
            longitude: 36.8007,
            label: 'Westlands, Nairobi',
          },
          area_label: 'Westlands',
        });

      expect(response.status).toBe(403);
      expect(response.body.success).toBe(false);
    });

    it('should fail without authentication', async () => {
      const response = await request(app)
        .post('/v1/properties')
        .send({
          type: 'apartment',
          title: 'Unauthorized Property',
          location: {
            latitude: -1.2634,
            longitude: 36.8007,
            label: 'Westlands, Nairobi',
          },
          area_label: 'Westlands',
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('PATCH /v1/properties/:id (Agent Owner/Admin)', () => {
    let property: any;

    beforeEach(async () => {
      property = await createTestProperty(pool, agent.id);
    });

    it('should update own property as agent', async () => {
      const response = await request(app)
        .patch(`/v1/properties/${property.id}`)
        .set('Authorization', `Bearer ${agentToken}`)
        .send({
          title: 'Updated Title',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.title).toBe('Updated Title');
    });

    it('should update any property as admin', async () => {
      const response = await request(app)
        .patch(`/v1/properties/${property.id}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          title: 'Admin Updated Title',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should fail for agent updating another agent\'s property', async () => {
      const otherAgent = await createTestUser(pool, {
        email: 'agent2@juax.test',
        password: 'Test123!@#',
        name: 'Other Agent',
        is_agent: true,
      });

      const loginResponse = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'agent2@juax.test',
          password: 'Test123!@#',
        });

      const otherAgentToken = loginResponse.body.data.tokens.accessToken;

      const response = await request(app)
        .patch(`/v1/properties/${property.id}`)
        .set('Authorization', `Bearer ${otherAgentToken}`)
        .send({
          title: 'Unauthorized Update',
        });

      expect(response.status).toBe(403);
      expect(response.body.success).toBe(false);
    });
  });

  describe('PATCH /v1/properties/:id/availability', () => {
    let property: any;

    beforeEach(async () => {
      property = await createTestProperty(pool, agent.id, {
        is_available: true,
      });
    });

    it('should toggle availability as agent owner', async () => {
      const response = await request(app)
        .patch(`/v1/properties/${property.id}/availability`)
        .set('Authorization', `Bearer ${agentToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.is_available).toBe(false);
    });

    it('should toggle availability as admin', async () => {
      const response = await request(app)
        .patch(`/v1/properties/${property.id}/availability`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });

  describe('DELETE /v1/properties/:id', () => {
    let property: any;

    beforeEach(async () => {
      property = await createTestProperty(pool, agent.id);
    });

    it('should delete own property as agent', async () => {
      const response = await request(app)
        .delete(`/v1/properties/${property.id}`)
        .set('Authorization', `Bearer ${agentToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);

      // Verify property is deleted
      const getResponse = await request(app)
        .get(`/v1/properties/${property.id}`);

      expect(getResponse.status).toBe(404);
    });

    it('should delete any property as admin', async () => {
      const response = await request(app)
        .delete(`/v1/properties/${property.id}`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });
  });
});
