import { MapboxService } from '../src/services/mapboxService';
import axios from 'axios';
import redisClient from '../src/config/redis';

jest.mock('axios');
jest.mock('../src/config/redis');
jest.mock('../src/config/env', () => ({
  config: {
    mapbox: {
      accessToken: 'test-token',
    },
  },
}));

describe('MapboxService', () => {
  let mapboxService: MapboxService;
  let mockAxios: jest.Mocked<typeof axios>;
  let mockRedis: jest.Mocked<typeof redisClient>;

  beforeEach(() => {
    mapboxService = new MapboxService();
    mockAxios = axios as jest.Mocked<typeof axios>;
    mockRedis = redisClient as jest.Mocked<typeof redisClient>;
    jest.clearAllMocks();
  });

  describe('validateKenyaBounds', () => {
    it('should return true for coordinates within Kenya', () => {
      expect(mapboxService.validateKenyaBounds(-1.2634, 36.8007)).toBe(true); // Nairobi
      expect(mapboxService.validateKenyaBounds(-0.0917, 34.7680)).toBe(true); // Kisumu
      expect(mapboxService.validateKenyaBounds(0.0236, 37.9062)).toBe(true); // Nyeri
    });

    it('should return false for coordinates outside Kenya', () => {
      expect(mapboxService.validateKenyaBounds(51.5074, -0.1278)).toBe(false); // London
      expect(mapboxService.validateKenyaBounds(40.7128, -74.0060)).toBe(false); // New York
      expect(mapboxService.validateKenyaBounds(-25.2744, 133.7751)).toBe(false); // Australia
    });
  });

  describe('geocode', () => {
    const mockGeocodeResponse = {
      data: {
        type: 'FeatureCollection',
        features: [
          {
            id: 'place.123',
            type: 'Feature',
            place_type: ['place'],
            relevance: 1,
            properties: {},
            text: 'Westlands',
            place_name: 'Westlands, Nairobi, Kenya',
            center: [36.8007, -1.2634],
            geometry: {
              type: 'Point',
              coordinates: [36.8007, -1.2634],
            },
            context: [
              {
                id: 'country.123',
                text: 'Kenya',
              },
              {
                id: 'region.123',
                text: 'Nairobi',
              },
            ],
          },
        ],
      },
    };

    it('should geocode address successfully', async () => {
      mockRedis.get.mockResolvedValue(null);
      mockRedis.setEx.mockResolvedValue('OK');
      mockAxios.get.mockResolvedValue(mockGeocodeResponse);

      const result = await mapboxService.geocode('Westlands, Nairobi');

      expect(result.latitude).toBe(-1.2634);
      expect(result.longitude).toBe(36.8007);
      expect(result.placeName).toContain('Westlands');
      expect(mockAxios.get).toHaveBeenCalledWith(
        expect.stringContaining('geocoding/v5/mapbox.places'),
        expect.objectContaining({
          params: expect.objectContaining({
            access_token: 'test-token',
            country: 'KE',
          }),
        })
      );
    });

    it('should use cached result if available', async () => {
      const cachedResult = {
        latitude: -1.2634,
        longitude: 36.8007,
        placeName: 'Westlands, Nairobi, Kenya',
        address: 'Westlands',
      };
      mockRedis.get.mockResolvedValue(JSON.stringify(cachedResult));

      const result = await mapboxService.geocode('Westlands, Nairobi');

      expect(result).toEqual(cachedResult);
      expect(mockAxios.get).not.toHaveBeenCalled();
    });

    it('should throw error for address outside Kenya', async () => {
      const outsideKenyaResponse = {
        data: {
          type: 'FeatureCollection',
          features: [
            {
              id: 'place.123',
              type: 'Feature',
              place_type: ['place'],
              relevance: 1,
              properties: {},
              text: 'London',
              place_name: 'London, UK',
              center: [-0.1278, 51.5074],
              geometry: {
                type: 'Point',
                coordinates: [-0.1278, 51.5074],
              },
            },
          ],
        },
      };

      mockRedis.get.mockResolvedValue(null);
      mockAxios.get.mockResolvedValue(outsideKenyaResponse);

      await expect(
        mapboxService.geocode('London, UK')
      ).rejects.toThrow('outside Kenya service area');
    });

    it('should throw error when address not found', async () => {
      mockRedis.get.mockResolvedValue(null);
      mockAxios.get.mockResolvedValue({
        data: {
          type: 'FeatureCollection',
          features: [],
        },
      });

      await expect(
        mapboxService.geocode('Nonexistent Place XYZ123')
      ).rejects.toThrow('Address not found');
    });
  });

  describe('reverseGeocode', () => {
    const mockReverseGeocodeResponse = {
      data: {
        type: 'FeatureCollection',
        features: [
          {
            id: 'place.123',
            type: 'Feature',
            place_type: ['place'],
            properties: {},
            place_name: 'Westlands, Nairobi, Kenya',
            center: [36.8007, -1.2634],
            geometry: {
              type: 'Point',
              coordinates: [36.8007, -1.2634],
            },
            context: [
              {
                id: 'country.123',
                text: 'Kenya',
              },
            ],
          },
        ],
      },
    };

    it('should reverse geocode coordinates successfully', async () => {
      mockRedis.get.mockResolvedValue(null);
      mockRedis.setEx.mockResolvedValue('OK');
      mockAxios.get.mockResolvedValue(mockReverseGeocodeResponse);

      const result = await mapboxService.reverseGeocode(-1.2634, 36.8007);

      expect(result.placeName).toContain('Westlands');
      expect(mockAxios.get).toHaveBeenCalled();
    });

    it('should throw error for coordinates outside Kenya', async () => {
      await expect(
        mapboxService.reverseGeocode(51.5074, -0.1278) // London
      ).rejects.toThrow('outside Kenya service area');
    });
  });

  describe('calculateDistance', () => {
    it('should calculate distance between two points', () => {
      // Nairobi to Kisumu (approximately 265 km)
      const result = mapboxService.calculateDistance(
        -1.2634, 36.8007, // Nairobi
        -0.0917, 34.7680  // Kisumu
      );

      expect(result.distance).toBeGreaterThan(200000); // > 200 km
      expect(result.distance).toBeLessThan(300000); // < 300 km
    });

    it('should throw error for invalid coordinates', () => {
      expect(() => {
        mapboxService.calculateDistance(100, 0, 0, 0); // Invalid lat
      }).toThrow('Invalid coordinates');
    });
  });

  describe('validateCoordinates', () => {
    it('should validate coordinates within Kenya', () => {
      const result = mapboxService.validateCoordinates(-1.2634, 36.8007);
      expect(result.valid).toBe(true);
      expect(result.inKenya).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject coordinates outside Kenya', () => {
      const result = mapboxService.validateCoordinates(51.5074, -0.1278);
      expect(result.valid).toBe(false);
      expect(result.inKenya).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
    });

    it('should reject invalid coordinate ranges', () => {
      const result = mapboxService.validateCoordinates(100, 200);
      expect(result.valid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
    });
  });
});
