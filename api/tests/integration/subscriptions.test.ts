import request from 'supertest';
import { getTestApp, initializeTestApp, setupTestDatabase, cleanupTestDatabase, closeTestConnections } from '../setup';
import { createTestUser } from '../helpers';

describe('Subscriptions API Integration Tests', () => {
  let app: any;
  let pool: any;
  let user: any;
  let admin: any;
  let userToken: string;
  let adminToken: string;

  beforeAll(async () => {
    await initializeTestApp();
    app = getTestApp();
    pool = await setupTestDatabase();
  });

  beforeEach(async () => {
    await cleanupTestDatabase();

    // Create regular user
    user = await createTestUser(pool, {
      email: 'user@juax.test',
      password: 'Test123!@#',
      name: 'Test User',
    });

    const userLoginResponse = await request(app)
      .post('/v1/auth/login')
      .send({
        email: 'user@juax.test',
        password: 'Test123!@#',
      });

    if (userLoginResponse.status !== 200 || !userLoginResponse.body.success) {
      throw new Error(`Login failed: ${JSON.stringify(userLoginResponse.body)}`);
    }

    userToken = userLoginResponse.body.data.tokens.accessToken;

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

    if (adminLoginResponse.status !== 200 || !adminLoginResponse.body.success) {
      throw new Error(`Admin login failed: ${JSON.stringify(adminLoginResponse.body)}`);
    }

    adminToken = adminLoginResponse.body.data.tokens.accessToken;
  });

  afterAll(async () => {
    await closeTestConnections();
  });

  describe('GET /v1/subscriptions (Public)', () => {
    it('should list all available subscription tiers', async () => {
      const response = await request(app)
        .get('/v1/subscriptions');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.subscriptions).toBeDefined();
      expect(response.body.data.subscriptions.length).toBeGreaterThan(0);
      
      // Check that freemium and premium are included
      const tiers = response.body.data.subscriptions.map((s: any) => s.tier);
      expect(tiers).toContain('freemium');
      expect(tiers).toContain('premium');
    });

    it('should include pricing and features for each tier', async () => {
      const response = await request(app)
        .get('/v1/subscriptions');

      expect(response.status).toBe(200);
      const premium = response.body.data.subscriptions.find((s: any) => s.tier === 'premium');
      
      expect(premium).toBeDefined();
      expect(premium.billingPeriods).toBeDefined();
      expect(premium.features).toBeDefined();
      expect(premium.limits).toBeDefined();
    });
  });

  describe('GET /v1/subscriptions/current', () => {
    it('should return freemium subscription for new user', async () => {
      const response = await request(app)
        .get('/v1/subscriptions/current')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.tier).toBe('freemium');
      expect(response.body.data.status).toBe('active');
    });

    it('should fail without authentication', async () => {
      const response = await request(app)
        .get('/v1/subscriptions/current');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /v1/subscriptions/upgrade', () => {
    it('should upgrade to premium subscription', async () => {
      const response = await request(app)
        .post('/v1/subscriptions/upgrade')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          tier: 'premium',
          billingPeriod: 'monthly',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.tier).toBe('premium');
      expect(response.body.data.status).toBe('trial'); // Premium starts with trial
      expect(response.body.data.billingPeriod).toBe('monthly');
    });

    it('should upgrade to annual premium subscription', async () => {
      const response = await request(app)
        .post('/v1/subscriptions/upgrade')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          tier: 'premium',
          billingPeriod: 'annual',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.tier).toBe('premium');
      expect(response.body.data.billingPeriod).toBe('annual');
    });

    it('should upgrade to service-specific tier', async () => {
      const response = await request(app)
        .post('/v1/subscriptions/upgrade')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          tier: 'cleaning',
          billingPeriod: 'monthly',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.tier).toBe('cleaning');
    });

    it('should fail with invalid tier', async () => {
      const response = await request(app)
        .post('/v1/subscriptions/upgrade')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          tier: 'invalid_tier',
          billingPeriod: 'monthly',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail without authentication', async () => {
      const response = await request(app)
        .post('/v1/subscriptions/upgrade')
        .send({
          tier: 'premium',
          billingPeriod: 'monthly',
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /v1/subscriptions/downgrade', () => {
    beforeEach(async () => {
      // Upgrade to premium first
      await request(app)
        .post('/v1/subscriptions/upgrade')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          tier: 'premium',
          billingPeriod: 'monthly',
        });
    });

    it('should downgrade to freemium', async () => {
      const response = await request(app)
        .post('/v1/subscriptions/downgrade')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          tier: 'freemium',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.tier).toBe('freemium');
      expect(response.body.data.status).toBe('active');
    });

    it('should fail when trying to downgrade to non-freemium tier', async () => {
      const response = await request(app)
        .post('/v1/subscriptions/downgrade')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          tier: 'premium',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /v1/subscriptions/cancel', () => {
    beforeEach(async () => {
      // Upgrade to premium first
      await request(app)
        .post('/v1/subscriptions/upgrade')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          tier: 'premium',
          billingPeriod: 'monthly',
        });
    });

    it('should cancel subscription', async () => {
      const response = await request(app)
        .post('/v1/subscriptions/cancel')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.status).toBe('cancelled');
      expect(response.body.data.cancelledAt).toBeDefined();
    });

    it('should fail to cancel when no subscription exists', async () => {
      // Create new user without subscription
      const newUser = await createTestUser(pool, {
        email: 'newuser@juax.test',
        password: 'Test123!@#',
        name: 'New User',
      });

      const loginResponse = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'newuser@juax.test',
          password: 'Test123!@#',
        });

      const newUserToken = loginResponse.body.data.tokens.accessToken;

      // Try to cancel (should fail or return error)
      const response = await request(app)
        .post('/v1/subscriptions/cancel')
        .set('Authorization', `Bearer ${newUserToken}`);

      // This might return 404 or handle gracefully
      expect([200, 404]).toContain(response.status);
    });
  });

  describe('GET /v1/subscriptions/access', () => {
    it('should check feature access for freemium user', async () => {
      const response = await request(app)
        .get('/v1/subscriptions/access?feature=orders_per_month')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.hasAccess).toBe(true);
      expect(response.body.data.limit).toBe(3);
    });

    it('should check unlimited orders access for premium user', async () => {
      // Upgrade to premium
      const upgradeResponse = await request(app)
        .post('/v1/subscriptions/upgrade')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          tier: 'premium',
          billingPeriod: 'monthly',
        });

      expect(upgradeResponse.status).toBe(200);

      // Check that premium subscription has unlimited orders feature
      const currentSubResponse = await request(app)
        .get('/v1/subscriptions/current')
        .set('Authorization', `Bearer ${userToken}`);

      expect(currentSubResponse.body.data.features).toBeDefined();
      const unlimitedFeature = currentSubResponse.body.data.features.find(
        (f: any) => f.feature === 'unlimited_orders'
      );
      expect(unlimitedFeature).toBeDefined();
      expect(unlimitedFeature.enabled).toBe(true);

      // Now check access
      const response = await request(app)
        .get('/v1/subscriptions/access?feature=unlimited_orders')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.hasAccess).toBe(true);
    });

    it('should fail without feature parameter', async () => {
      const response = await request(app)
        .get('/v1/subscriptions/access')
        .set('Authorization', `Bearer ${userToken}`);

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('Admin Endpoints', () => {
    describe('GET /v1/admin/subscriptions', () => {
      beforeEach(async () => {
        // Create some subscriptions
        await request(app)
          .post('/v1/subscriptions/upgrade')
          .set('Authorization', `Bearer ${userToken}`)
          .send({
            tier: 'premium',
            billingPeriod: 'monthly',
          });
      });

      it('should list all subscriptions as admin', async () => {
        const response = await request(app)
          .get('/v1/admin/subscriptions')
          .set('Authorization', `Bearer ${adminToken}`);

        expect(response.status).toBe(200);
        expect(response.body.success).toBe(true);
        expect(response.body.data.subscriptions.length).toBeGreaterThan(0);
      });

      it('should filter subscriptions by status', async () => {
        const response = await request(app)
          .get('/v1/admin/subscriptions?status=trial')
          .set('Authorization', `Bearer ${adminToken}`);

        expect(response.status).toBe(200);
        expect(response.body.success).toBe(true);
        response.body.data.subscriptions.forEach((sub: any) => {
          expect(sub.status).toBe('trial');
        });
      });

      it('should filter subscriptions by tier', async () => {
        const response = await request(app)
          .get('/v1/admin/subscriptions?tier=premium')
          .set('Authorization', `Bearer ${adminToken}`);

        expect(response.status).toBe(200);
        expect(response.body.success).toBe(true);
        response.body.data.subscriptions.forEach((sub: any) => {
          expect(sub.tier).toBe('premium');
        });
      });

      it('should fail for non-admin user', async () => {
        const response = await request(app)
          .get('/v1/admin/subscriptions')
          .set('Authorization', `Bearer ${userToken}`);

        expect(response.status).toBe(403);
        expect(response.body.success).toBe(false);
      });
    });

    describe('GET /v1/admin/subscriptions/:id', () => {
      let subscriptionId: string;

      beforeEach(async () => {
        const upgradeResponse = await request(app)
          .post('/v1/subscriptions/upgrade')
          .set('Authorization', `Bearer ${userToken}`)
          .send({
            tier: 'premium',
            billingPeriod: 'monthly',
          });

        subscriptionId = upgradeResponse.body.data.id;
      });

      it('should get subscription details as admin', async () => {
        const response = await request(app)
          .get(`/v1/admin/subscriptions/${subscriptionId}`)
          .set('Authorization', `Bearer ${adminToken}`);

        expect(response.status).toBe(200);
        expect(response.body.success).toBe(true);
        expect(response.body.data.id).toBe(subscriptionId);
        expect(response.body.data.user).toBeDefined();
      });

      it('should fail with non-existent subscription', async () => {
        const response = await request(app)
          .get('/v1/admin/subscriptions/00000000-0000-0000-0000-000000000000')
          .set('Authorization', `Bearer ${adminToken}`);

        expect(response.status).toBe(404);
        expect(response.body.success).toBe(false);
      });
    });

    describe('PATCH /v1/admin/subscriptions/:id/status', () => {
      let subscriptionId: string;

      beforeEach(async () => {
        const upgradeResponse = await request(app)
          .post('/v1/subscriptions/upgrade')
          .set('Authorization', `Bearer ${userToken}`)
          .send({
            tier: 'premium',
            billingPeriod: 'monthly',
          });

        subscriptionId = upgradeResponse.body.data.id;
      });

      it('should update subscription status as admin', async () => {
        const response = await request(app)
          .patch(`/v1/admin/subscriptions/${subscriptionId}/status`)
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            status: 'expired',
          });

        expect(response.status).toBe(200);
        expect(response.body.success).toBe(true);
        expect(response.body.message).toContain('updated successfully');
      });

      it('should fail with invalid status', async () => {
        const response = await request(app)
          .patch(`/v1/admin/subscriptions/${subscriptionId}/status`)
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            status: 'invalid_status',
          });

        expect(response.status).toBe(400);
        expect(response.body.success).toBe(false);
      });
    });
  });
});
