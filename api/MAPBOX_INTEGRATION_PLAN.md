# Stage 5: Mapbox Integration Plan

## Overview
Integrate Mapbox services into the JuaX API to enhance location handling, validation, and provide geocoding capabilities.

## What's Needed

### 1. **Mapbox Account & Access Token** 🔑
- **Required**: Mapbox account (free tier available)
- **Action**: Get access token from https://account.mapbox.com/
- **Storage**: Already configured in `.env` as `MAPBOX_ACCESS_TOKEN`

### 2. **Mapbox Services to Integrate**

#### A. **Geocoding API** (Address → Coordinates)
- **Purpose**: Convert human-readable addresses to coordinates
- **Use Case**: When users provide address strings, convert to lat/lng for storage
- **Endpoint**: `GET /v1/locations/geocode?address=...`

#### B. **Reverse Geocoding API** (Coordinates → Address)
- **Purpose**: Convert coordinates to human-readable addresses
- **Use Case**: Enrich order locations with full address details
- **Endpoint**: `GET /v1/locations/reverse-geocode?lat=...&lng=...`

#### C. **Location Validation**
- **Purpose**: Validate coordinates are within service area (Kenya)
- **Use Case**: Ensure orders are within service boundaries
- **Integration**: Built into order creation validation

#### D. **Distance Calculation** (Optional but Recommended)
- **Purpose**: Calculate distances between two points
- **Use Case**: Estimate delivery/service times, service radius checks
- **Endpoint**: `GET /v1/locations/distance?from=...&to=...`

### 3. **Implementation Components**

#### **Service Layer** (`src/services/mapboxService.ts`)
- Geocoding function
- Reverse geocoding function
- Distance calculation function
- Location validation (Kenya bounds)
- Error handling for Mapbox API errors
- Rate limiting awareness (Mapbox has rate limits)

#### **Controller Layer** (`src/controllers/locationController.ts`)
- Geocoding endpoint handler
- Reverse geocoding endpoint handler
- Distance calculation endpoint handler

#### **Routes** (`src/routes/locationRoutes.ts`)
- Public routes (no auth required for basic geocoding)
- Rate limited to prevent abuse

#### **Integration Points**
- **Order Service**: Use reverse geocoding to enrich location labels
- **Order Validation**: Use location validation to ensure service area
- **Future**: Distance calculation for delivery estimates

### 4. **Dependencies**

```json
{
  "@mapbox/mapbox-sdk": "^0.13.0"  // Official Mapbox SDK
}
```

**OR** (simpler approach):
```json
{
  "axios": "^1.6.2"  // Already installed, use for direct API calls
}
```

**Recommendation**: Use `axios` (already installed) for direct API calls - simpler and more control.

### 5. **API Endpoints to Create**

```
GET  /v1/locations/geocode          # Address → Coordinates
GET  /v1/locations/reverse-geocode   # Coordinates → Address  
GET  /v1/locations/distance           # Calculate distance
GET  /v1/locations/validate           # Validate coordinates
```

### 6. **Error Handling**

- Mapbox API errors (rate limits, invalid requests)
- Network errors
- Invalid coordinates/addresses
- Service area validation failures

### 7. **Caching Strategy** (Optional but Recommended)

- Cache geocoding results in Redis (addresses don't change often)
- Cache reverse geocoding results
- TTL: 7 days for addresses, 30 days for coordinates

### 8. **Testing Requirements**

- Unit tests for Mapbox service functions
- Integration tests with mock Mapbox responses
- Test error handling (rate limits, invalid inputs)
- Test Kenya boundary validation

## Implementation Steps

1. ✅ **Install dependencies** (if needed - axios already installed)
2. ✅ **Create Mapbox service** (`src/services/mapboxService.ts`)
3. ✅ **Create location controller** (`src/controllers/locationController.ts`)
4. ✅ **Create location routes** (`src/routes/locationRoutes.ts`)
5. ✅ **Integrate with order service** (enhance location labels)
6. ✅ **Add location validation** (Kenya bounds check)
7. ✅ **Add caching** (Redis for geocoding results)
8. ✅ **Write tests** (unit + integration)
9. ✅ **Update documentation** (API docs)

## Kenya Service Area Bounds

```typescript
const KENYA_BOUNDS = {
  north: 5.506,   // Northernmost point
  south: -4.679,   // Southernmost point
  east: 41.899,   // Easternmost point
  west: 33.909    // Westernmost point
};
```

## Mapbox API Rate Limits (Free Tier)

- **Geocoding**: 100,000 requests/month
- **Reverse Geocoding**: 100,000 requests/month
- **Requests per second**: 600 requests/second

**Note**: Caching will help stay within limits.

## Cost Considerations

- **Free Tier**: 100,000 requests/month (more than enough for MVP)
- **Paid Tier**: $0.75 per 1,000 requests after free tier
- **Recommendation**: Use caching aggressively to minimize API calls

## Security Considerations

- Keep Mapbox token in `.env` (never commit)
- Rate limit endpoints to prevent abuse
- Validate all inputs before calling Mapbox API
- Sanitize address inputs to prevent injection

## Next Steps After Implementation

1. Monitor Mapbox API usage
2. Optimize caching strategy based on usage patterns
3. Add route optimization (for future delivery/ride services)
4. Add isochrone API (service area visualization)

---

## Ready to Proceed?

**What I need from you:**
1. ✅ Mapbox access token (or I can use a placeholder for now)
2. ✅ Confirmation to proceed with implementation

**What I'll deliver:**
- ✅ Complete Mapbox service integration
- ✅ Location endpoints (geocode, reverse-geocode, distance, validate)
- ✅ Integration with order service
- ✅ Caching layer
- ✅ Comprehensive tests
- ✅ Updated documentation

Let me know if you want to proceed! 🚀
