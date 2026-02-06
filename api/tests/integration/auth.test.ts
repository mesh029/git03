import request from 'supertest';
import { getTestApp, initializeTestApp, setupTestDatabase, cleanupTestDatabase, closeTestConnections } from '../setup';
import { createTestUser } from '../helpers';

describe('Auth API Integration Tests', () => {
  let app: any;
  let pool: any;

  beforeAll(async () => {
    await initializeTestApp();
    app = getTestApp();
    pool = await setupTestDatabase();
  });

  afterEach(async () => {
    await cleanupTestDatabase();
  });

  afterAll(async () => {
    await closeTestConnections();
  });

  describe('POST /v1/auth/register', () => {
    it('should register a new user successfully', async () => {
      const response = await request(app)
        .post('/v1/auth/register')
        .send({
          email: 'user1@juax.test',
          password: 'Test123!@#',
          name: 'John Doe',
          phone: '+254712345678',
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe('user1@juax.test');
      expect(response.body.data.user.name).toBe('John Doe');
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();
    });

    it('should fail with duplicate email', async () => {
      // Create first user
      await createTestUser(pool, {
        email: 'existing@juax.test',
        password: 'Test123!@#',
        name: 'Existing User',
      });

      // Try to register with same email
      const response = await request(app)
        .post('/v1/auth/register')
        .send({
          email: 'existing@juax.test',
          password: 'Test123!@#',
          name: 'New User',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toContain('already registered');
    });

    it('should fail with invalid email format', async () => {
      const response = await request(app)
        .post('/v1/auth/register')
        .send({
          email: 'invalid-email',
          password: 'Test123!@#',
          name: 'Test User',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail with weak password', async () => {
      const response = await request(app)
        .post('/v1/auth/register')
        .send({
          email: 'user@juax.test',
          password: 'weak',
          name: 'Test User',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail with missing required fields', async () => {
      const response = await request(app)
        .post('/v1/auth/register')
        .send({
          email: 'user@juax.test',
          // Missing password and name
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /v1/auth/login', () => {
    beforeEach(async () => {
      await createTestUser(pool, {
        email: 'user1@juax.test',
        password: 'Test123!@#',
        name: 'John Doe',
      });
    });

    it('should login with valid credentials', async () => {
      const response = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'user1@juax.test',
          password: 'Test123!@#',
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.user.email).toBe('user1@juax.test');
      expect(response.body.data.tokens.accessToken).toBeDefined();
      expect(response.body.data.tokens.refreshToken).toBeDefined();
    });

    it('should fail with invalid email', async () => {
      const response = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'nonexistent@juax.test',
          password: 'Test123!@#',
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should fail with wrong password', async () => {
      const response = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'user1@juax.test',
          password: 'WrongPassword123!@#',
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should fail with missing fields', async () => {
      const response = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'user1@juax.test',
          // Missing password
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /v1/auth/refresh', () => {
    let refreshToken: string;

    beforeEach(async () => {
      const user = await createTestUser(pool, {
        email: 'user1@juax.test',
        password: 'Test123!@#',
        name: 'John Doe',
      });

      // Login to get refresh token
      const loginResponse = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'user1@juax.test',
          password: 'Test123!@#',
        });

      refreshToken = loginResponse.body.data.tokens.refreshToken;
    });

    it('should refresh tokens successfully', async () => {
      const response = await request(app)
        .post('/v1/auth/refresh')
        .send({
          refreshToken,
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.accessToken).toBeDefined();
      expect(response.body.data.refreshToken).toBeDefined();
    });

    it('should fail with invalid refresh token', async () => {
      const response = await request(app)
        .post('/v1/auth/refresh')
        .send({
          refreshToken: 'invalid-token',
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /v1/auth/me', () => {
    let accessToken: string;

    beforeEach(async () => {
      const user = await createTestUser(pool, {
        email: 'user1@juax.test',
        password: 'Test123!@#',
        name: 'John Doe',
      });

      // Login to get access token
      const loginResponse = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'user1@juax.test',
          password: 'Test123!@#',
        });

      accessToken = loginResponse.body.data.tokens.accessToken;
    });

    it('should get current user info with valid token', async () => {
      const response = await request(app)
        .get('/v1/auth/me')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.email).toBe('user1@juax.test');
      expect(response.body.data.name).toBe('John Doe');
    });

    it('should fail without token', async () => {
      const response = await request(app)
        .get('/v1/auth/me');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should fail with invalid token', async () => {
      const response = await request(app)
        .get('/v1/auth/me')
        .set('Authorization', 'Bearer invalid-token');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /v1/auth/logout', () => {
    let accessToken: string;
    let refreshToken: string;

    beforeEach(async () => {
      const user = await createTestUser(pool, {
        email: 'user1@juax.test',
        password: 'Test123!@#',
        name: 'John Doe',
      });

      // Login to get tokens
      const loginResponse = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'user1@juax.test',
          password: 'Test123!@#',
        });

      accessToken = loginResponse.body.data.tokens.accessToken;
      refreshToken = loginResponse.body.data.refreshToken;
    });

    it('should logout successfully', async () => {
      const response = await request(app)
        .post('/v1/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);

      // Verify refresh token is invalidated
      const refreshResponse = await request(app)
        .post('/v1/auth/refresh')
        .send({ refreshToken });

      expect(refreshResponse.status).toBe(401);
    });

    it('should fail without token', async () => {
      const response = await request(app)
        .post('/v1/auth/logout');

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });
  });
});
