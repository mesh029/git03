import request from 'supertest';
import { getTestApp, initializeTestApp, setupTestDatabase, cleanupTestDatabase, closeTestConnections } from '../setup';

describe('Locations API Integration Tests', () => {
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

  describe('GET /v1/locations/geocode', () => {
    it('should geocode valid address in Kenya', async () => {
      const response = await request(app)
        .get('/v1/locations/geocode?address=Westlands, Nairobi');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.coordinates).toBeDefined();
      expect(response.body.data.coordinates.latitude).toBeDefined();
      expect(response.body.data.coordinates.longitude).toBeDefined();
      expect(response.body.data.label).toBeDefined();
    });

    it('should geocode with country parameter', async () => {
      const response = await request(app)
        .get('/v1/locations/geocode?address=Westlands&country=Kenya');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
    });

    it('should fail with missing address parameter', async () => {
      const response = await request(app)
        .get('/v1/locations/geocode');

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /v1/locations/reverse-geocode', () => {
    it('should reverse geocode valid coordinates in Kenya', async () => {
      const response = await request(app)
        .get('/v1/locations/reverse-geocode?lat=-1.2634&lng=36.8007');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.address).toBeDefined();
      expect(response.body.data.label).toBeDefined();
    });

    it('should fail with invalid coordinates', async () => {
      const response = await request(app)
        .get('/v1/locations/reverse-geocode?lat=999&lng=999');

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail with missing parameters', async () => {
      const response = await request(app)
        .get('/v1/locations/reverse-geocode?lat=-1.2634');

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /v1/locations/distance', () => {
    it('should calculate distance between two points', async () => {
      const response = await request(app)
        .get('/v1/locations/distance?fromLat=-1.2634&fromLng=36.8007&toLat=-0.0917&toLng=34.7680');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.distance).toBeDefined();
      expect(response.body.data.distance).toBeGreaterThan(0);
      expect(response.body.data.unit).toBe('km');
    });

    it('should fail with invalid coordinates', async () => {
      const response = await request(app)
        .get('/v1/locations/distance?fromLat=999&fromLng=999&toLat=-0.0917&toLng=34.7680');

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail with missing parameters', async () => {
      const response = await request(app)
        .get('/v1/locations/distance?fromLat=-1.2634&fromLng=36.8007');

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /v1/locations/validate', () => {
    it('should validate coordinates within Kenya', async () => {
      const response = await request(app)
        .get('/v1/locations/validate?lat=-1.2634&lng=36.8007');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.valid).toBe(true);
      expect(response.body.data.country).toBe('Kenya');
    });

    it('should invalidate coordinates outside Kenya', async () => {
      const response = await request(app)
        .get('/v1/locations/validate?lat=40.7128&lng=-74.0060'); // New York

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.valid).toBe(false);
    });

    it('should fail with invalid coordinate ranges', async () => {
      const response = await request(app)
        .get('/v1/locations/validate?lat=999&lng=999');

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });
});
