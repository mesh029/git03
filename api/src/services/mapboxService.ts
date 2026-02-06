import axios, { AxiosError } from 'axios';
import { config } from '../config/env';
import redisClient from '../config/redis';
import { ValidationError } from '../utils/errors';
import { logWarn } from '../utils/logger';

const MAPBOX_BASE_URL = 'https://api.mapbox.com';

// Kenya service area bounds
const KENYA_BOUNDS = {
  north: 5.506,   // Northernmost point
  south: -4.679,  // Southernmost point
  east: 41.899,    // Easternmost point
  west: 33.909,    // Westernmost point
};

interface GeocodeResponse {
  type: string;
  features: Array<{
    id: string;
    type: string;
    place_type: string[];
    relevance: number;
    properties: {
      accuracy?: string;
    };
    text: string;
    place_name: string;
    center: [number, number]; // [longitude, latitude]
    geometry: {
      type: string;
      coordinates: [number, number];
    };
    context?: Array<{
      id: string;
      text: string;
      short_code?: string;
    }>;
  }>;
}

interface ReverseGeocodeResponse {
  type: string;
  features: Array<{
    id: string;
    type: string;
    place_type: string[];
    properties: {
      accuracy?: string;
    };
    place_name: string;
    center: [number, number];
    geometry: {
      type: string;
      coordinates: [number, number];
    };
    context?: Array<{
      id: string;
      text: string;
      short_code?: string;
    }>;
  }>;
}

export interface GeocodeResult {
  latitude: number;
  longitude: number;
  placeName: string;
  address: string;
  context?: {
    country?: string;
    region?: string;
    district?: string;
    locality?: string;
  };
}

export interface ReverseGeocodeResult {
  placeName: string;
  address: string;
  context?: {
    country?: string;
    region?: string;
    district?: string;
    locality?: string;
  };
}

export interface DistanceResult {
  distance: number; // in meters
  duration?: number; // in seconds (if routing available)
}

export class MapboxService {
  private accessToken: string;

  constructor() {
    this.accessToken = config.mapbox.accessToken;
    if (!this.accessToken) {
      logWarn('Mapbox access token not configured');
    }
  }

  /**
   * Validate coordinates are within Kenya bounds
   */
  validateKenyaBounds(latitude: number, longitude: number): boolean {
    return (
      latitude >= KENYA_BOUNDS.south &&
      latitude <= KENYA_BOUNDS.north &&
      longitude >= KENYA_BOUNDS.west &&
      longitude <= KENYA_BOUNDS.east
    );
  }

  /**
   * Get cache key for geocoding
   */
  private getGeocodeCacheKey(address: string): string {
    return `mapbox:geocode:${address.toLowerCase().trim()}`;
  }

  /**
   * Get cache key for reverse geocoding
   */
  private getReverseGeocodeCacheKey(lat: number, lng: number): string {
    return `mapbox:reverse:${lat.toFixed(6)}:${lng.toFixed(6)}`;
  }

  /**
   * Extract context from Mapbox feature
   */
  private extractContext(feature: GeocodeResponse['features'][0]): GeocodeResult['context'] {
    const context: GeocodeResult['context'] = {};
    
    if (feature.context) {
      feature.context.forEach((ctx) => {
        if (ctx.id.startsWith('country')) {
          context.country = ctx.text;
        } else if (ctx.id.startsWith('region')) {
          context.region = ctx.text;
        } else if (ctx.id.startsWith('district')) {
          context.district = ctx.text;
        } else if (ctx.id.startsWith('locality') || ctx.id.startsWith('place')) {
          context.locality = ctx.text;
        }
      });
    }

    return Object.keys(context).length > 0 ? context : undefined;
  }

  /**
   * Geocode: Convert address to coordinates
   */
  async geocode(address: string, countryCode: string = 'KE'): Promise<GeocodeResult> {
    if (!this.accessToken) {
      throw new ValidationError('Mapbox service not configured', {
        code: 'MAPBOX_NOT_CONFIGURED',
      });
    }

    // Check cache first
    const cacheKey = this.getGeocodeCacheKey(address);
    try {
      const cached = await redisClient.get(cacheKey);
      if (cached) {
        return JSON.parse(cached);
      }
    } catch (error) {
      // Cache miss or error - continue with API call
      logWarn('Cache read error', {
        context: 'geocode',
        error: error instanceof Error ? error.message : String(error),
      });
    }

    try {
      const response = await axios.get<GeocodeResponse>(
        `${MAPBOX_BASE_URL}/geocoding/v5/mapbox.places/${encodeURIComponent(address)}.json`,
        {
          params: {
            access_token: this.accessToken,
            country: countryCode,
            limit: 1,
            types: 'address,poi,place',
          },
          timeout: 5000,
        }
      );

      if (!response.data.features || response.data.features.length === 0) {
        throw new ValidationError('Address not found', {
          code: 'ADDRESS_NOT_FOUND',
          field: 'address',
        });
      }

      const feature = response.data.features[0];
      const [longitude, latitude] = feature.center;

      // Validate Kenya bounds
      if (!this.validateKenyaBounds(latitude, longitude)) {
        throw new ValidationError('Address is outside Kenya service area', {
          code: 'OUTSIDE_SERVICE_AREA',
        });
      }

      const result: GeocodeResult = {
        latitude,
        longitude,
        placeName: feature.place_name,
        address: feature.text || feature.place_name,
        context: this.extractContext(feature),
      };

      // Cache result (7 days)
      try {
        await redisClient.setEx(cacheKey, 7 * 24 * 60 * 60, JSON.stringify(result));
      } catch (error) {
        logWarn('Cache write error', {
          context: 'geocode',
          error: error instanceof Error ? error.message : String(error),
        });
      }

      return result;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError<{ message?: string }>;
        if (axiosError.response?.status === 401) {
          throw new ValidationError('Invalid Mapbox access token', {
            code: 'MAPBOX_AUTH_ERROR',
          });
        }
        if (axiosError.response?.status === 429) {
          throw new ValidationError('Mapbox rate limit exceeded', {
            code: 'MAPBOX_RATE_LIMIT',
          });
        }
        throw new ValidationError(
          axiosError.response?.data?.message || 'Geocoding failed',
          {
            code: 'GEOCODING_ERROR',
          }
        );
      }
      throw error;
    }
  }

  /**
   * Reverse Geocode: Convert coordinates to address
   */
  async reverseGeocode(latitude: number, longitude: number): Promise<ReverseGeocodeResult> {
    if (!this.accessToken) {
      throw new ValidationError('Mapbox service not configured', {
        code: 'MAPBOX_NOT_CONFIGURED',
      });
    }

    // Validate Kenya bounds first
    if (!this.validateKenyaBounds(latitude, longitude)) {
      throw new ValidationError('Coordinates are outside Kenya service area', {
        code: 'OUTSIDE_SERVICE_AREA',
      });
    }

    // Check cache first
    const cacheKey = this.getReverseGeocodeCacheKey(latitude, longitude);
    try {
      const cached = await redisClient.get(cacheKey);
      if (cached) {
        return JSON.parse(cached);
      }
    } catch (error) {
      logWarn('Cache read error', {
        context: 'reverse_geocode',
        error: error instanceof Error ? error.message : String(error),
      });
    }

    try {
      const response = await axios.get<ReverseGeocodeResponse>(
        `${MAPBOX_BASE_URL}/geocoding/v5/mapbox.places/${longitude},${latitude}.json`,
        {
          params: {
            access_token: this.accessToken,
            limit: 1,
            types: 'address,poi,place',
          },
          timeout: 5000,
        }
      );

      if (!response.data.features || response.data.features.length === 0) {
        throw new ValidationError('Location not found', {
          code: 'LOCATION_NOT_FOUND',
        });
      }

      const feature = response.data.features[0];
      const context = this.extractContext(feature as any);

      const result: ReverseGeocodeResult = {
        placeName: feature.place_name,
        address: feature.place_name,
        context,
      };

      // Cache result (30 days - coordinates are stable)
      try {
        await redisClient.setEx(cacheKey, 30 * 24 * 60 * 60, JSON.stringify(result));
      } catch (error) {
        logWarn('Cache write error', {
          context: 'reverse_geocode',
          error: error instanceof Error ? error.message : String(error),
        });
      }

      return result;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        const axiosError = error as AxiosError<{ message?: string }>;
        if (axiosError.response?.status === 401) {
          throw new ValidationError('Invalid Mapbox access token', {
            code: 'MAPBOX_AUTH_ERROR',
          });
        }
        if (axiosError.response?.status === 429) {
          throw new ValidationError('Mapbox rate limit exceeded', {
            code: 'MAPBOX_RATE_LIMIT',
          });
        }
        throw new ValidationError(
          axiosError.response?.data?.message || 'Reverse geocoding failed',
          {
            code: 'REVERSE_GEOCODING_ERROR',
          }
        );
      }
      throw error;
    }
  }

  /**
   * Calculate distance between two points (Haversine formula)
   * Returns distance in meters
   */
  calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number
  ): DistanceResult {
    // Validate inputs
    if (
      lat1 < -90 || lat1 > 90 ||
      lat2 < -90 || lat2 > 90 ||
      lon1 < -180 || lon1 > 180 ||
      lon2 < -180 || lon2 > 180
    ) {
      throw new ValidationError('Invalid coordinates', {
        code: 'INVALID_COORDINATES',
      });
    }

    // Haversine formula
    const R = 6371000; // Earth radius in meters
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    const distance = R * c;

    return {
      distance: Math.round(distance),
    };
  }

  /**
   * Validate coordinates
   */
  validateCoordinates(latitude: number, longitude: number): {
    valid: boolean;
    inKenya: boolean;
    errors: string[];
  } {
    const errors: string[] = [];

    // Check coordinate ranges
    if (latitude < -90 || latitude > 90) {
      errors.push('Latitude must be between -90 and 90');
    }
    if (longitude < -180 || longitude > 180) {
      errors.push('Longitude must be between -180 and 180');
    }

    const valid = errors.length === 0;
    const inKenya = valid && this.validateKenyaBounds(latitude, longitude);

    if (valid && !inKenya) {
      errors.push('Coordinates are outside Kenya service area');
    }

    return {
      valid: errors.length === 0,
      inKenya,
      errors,
    };
  }
}

export const mapboxService = new MapboxService();
