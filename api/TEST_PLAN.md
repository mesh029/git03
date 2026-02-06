# JuaX API - Test Plan & Test Data

## Overview
This document outlines the comprehensive test plan for the JuaX API MVP, including test data, test scenarios, and step-by-step testing procedures.

## Prerequisites

1. **Environment Setup**
   - Docker and Docker Compose installed
   - Node.js 18+ installed
   - PostgreSQL client (optional, for direct DB access)
   - Redis client (optional, for direct Redis access)

2. **Services Running**
   - PostgreSQL (via Docker Compose)
   - Redis (via Docker Compose)
   - API Server (via `npm run dev`)

## Test Data

### Test Users

#### Regular User 1
- **Email**: `user1@juax.test`
- **Password**: `Test123!@#`
- **Name**: `John Doe`
- **Phone**: `+254712345678`
- **Role**: Regular user (not admin, not agent)

#### Regular User 2
- **Email**: `user2@juax.test`
- **Password**: `Test123!@#`
- **Name**: `Jane Smith`
- **Phone**: `+254712345679`
- **Role**: Regular user

#### Agent User
- **Email**: `agent@juax.test`
- **Password**: `Agent123!@#`
- **Name**: `Agent Williams`
- **Phone**: `+254712345680`
- **Role**: Agent (can manage properties)

#### Admin User
- **Email**: `admin@juax.test`
- **Password**: `Admin123!@#`
- **Name**: `Admin User`
- **Phone**: `+254712345681`
- **Role**: Admin

### Test Properties

#### Property 1: Luxury Apartment
- **Type**: `apartment`
- **Title**: `Modern 2BR Apartment in Westlands`
- **Location**: Latitude `-1.2634`, Longitude `36.8007`, Label `Westlands, Nairobi`
- **Area Label**: `Westlands`
- **Price Label**: `KES 15,000/night`
- **Rating**: `4.5`
- **Traction**: `120 bookings`
- **Amenities**: `WiFi`, `Parking`, `Kitchen`, `AC`
- **House Rules**: `No smoking, No parties`
- **Images**: `['https://example.com/prop1-1.jpg', 'https://example.com/prop1-2.jpg']`
- **Available**: `true`

#### Property 2: Cozy BnB
- **Type**: `bnb`
- **Title**: `Cozy Studio BnB in Kisumu`
- **Location**: Latitude `-0.0917`, Longitude `34.7680`, Label `Milimani Road, Kisumu`
- **Area Label**: `Milimani`
- **Price Label**: `KES 5,000/night`
- **Rating**: `4.2`
- **Traction**: `85 bookings`
- **Amenities**: `WiFi`, `Kitchen`
- **House Rules**: `Check-in after 2PM`
- **Images**: `['https://example.com/prop2-1.jpg']`
- **Available**: `true`

#### Property 3: Unavailable Property
- **Type**: `apartment`
- **Title**: `Temporarily Unavailable Apartment`
- **Location**: Latitude `-1.2921`, Longitude `36.8219`, Label `CBD, Nairobi`
- **Area Label**: `CBD`
- **Price Label**: `KES 10,000/night`
- **Rating**: `4.0`
- **Traction**: `50 bookings`
- **Amenities**: `WiFi`
- **House Rules**: `Standard rules`
- **Images**: `[]`
- **Available**: `false`

## Test Scenarios

### Phase 1: Authentication Tests

#### 1.1 User Registration
**Endpoint**: `POST /v1/auth/register`

**Test Cases**:
- ✅ Register new user with valid data
- ✅ Register with duplicate email (should fail)
- ✅ Register with invalid email format (should fail)
- ✅ Register with weak password (should fail)
- ✅ Register with missing required fields (should fail)

**Sample Request**:
```json
{
  "email": "user1@juax.test",
  "password": "Test123!@#",
  "name": "John Doe",
  "phone": "+254712345678"
}
```

#### 1.2 User Login
**Endpoint**: `POST /v1/auth/login`

**Test Cases**:
- ✅ Login with valid credentials
- ✅ Login with invalid email (should fail)
- ✅ Login with wrong password (should fail)
- ✅ Login with missing fields (should fail)

**Sample Request**:
```json
{
  "email": "user1@juax.test",
  "password": "Test123!@#"
}
```

#### 1.3 Token Refresh
**Endpoint**: `POST /v1/auth/refresh`

**Test Cases**:
- ✅ Refresh with valid refresh token
- ✅ Refresh with invalid token (should fail)
- ✅ Refresh with expired token (should fail)

#### 1.4 Get Current User
**Endpoint**: `GET /v1/auth/me`

**Test Cases**:
- ✅ Get user info with valid token
- ✅ Get user info without token (should fail)
- ✅ Get user info with invalid token (should fail)

#### 1.5 Logout
**Endpoint**: `POST /v1/auth/logout`

**Test Cases**:
- ✅ Logout with valid refresh token
- ✅ Logout with invalid token (should fail)

### Phase 2: Order Creation Tests

#### 2.1 Create Cleaning Order
**Endpoint**: `POST /v1/orders`

**Test Cases**:
- ✅ Create cleaning order with valid data
- ✅ Create with invalid location coordinates (should fail)
- ✅ Create with missing location label (should fail)
- ✅ Create without authentication (should fail)

**Sample Request**:
```json
{
  "type": "cleaning",
  "location": {
    "latitude": -1.2634,
    "longitude": 36.8007,
    "label": "Westlands, Nairobi"
  },
  "details": {
    "service": "deepCleaning",
    "rooms": 3
  }
}
```

#### 2.2 Create Laundry Order
**Endpoint**: `POST /v1/orders`

**Sample Request**:
```json
{
  "type": "laundry",
  "location": {
    "latitude": -0.0917,
    "longitude": 34.7680,
    "label": "Milimani Road, Kisumu"
  },
  "details": {
    "serviceType": "washAndFold",
    "quantity": 5,
    "items": ["shirts", "pants", "towels"]
  }
}
```

#### 2.3 Create Property Booking Order
**Endpoint**: `POST /v1/orders`

**Test Cases**:
- ✅ Create property booking with valid dates
- ✅ Create booking with conflicting dates (should fail)
- ✅ Create booking for unavailable property (should fail)
- ✅ Create booking with check-in in the past (should fail)
- ✅ Create booking with check-out before check-in (should fail)
- ✅ Create booking with too many guests (should fail)

**Sample Request**:
```json
{
  "type": "property_booking",
  "location": {
    "latitude": -0.0917,
    "longitude": 34.7680,
    "label": "Milimani Road, Kisumu"
  },
  "details": {
    "propertyId": "<property-id-from-seed>",
    "checkIn": "2024-02-15T14:00:00Z",
    "checkOut": "2024-02-18T11:00:00Z",
    "guests": 2
  }
}
```

### Phase 3: Order Retrieval Tests

#### 3.1 List User Orders
**Endpoint**: `GET /v1/orders`

**Test Cases**:
- ✅ List all orders for authenticated user
- ✅ Filter by status (pending, cancelled)
- ✅ Filter by type (cleaning, laundry, property_booking)
- ✅ Pagination (limit, offset)
- ✅ List orders without authentication (should fail)
- ✅ List orders for another user (should return empty)

**Query Parameters**:
- `status`: `pending` | `cancelled`
- `type`: `cleaning` | `laundry` | `property_booking`
- `limit`: `1-100` (default: 20)
- `offset`: `0+` (default: 0)

#### 3.2 Get Single Order
**Endpoint**: `GET /v1/orders/:id`

**Test Cases**:
- ✅ Get own order by ID
- ✅ Get another user's order (should fail with 403)
- ✅ Get non-existent order (should fail with 404)
- ✅ Get order without authentication (should fail)

### Phase 4: Order Cancellation Tests

#### 4.1 Cancel Order
**Endpoint**: `PATCH /v1/orders/:id/cancel`

**Test Cases**:
- ✅ Cancel pending order
- ✅ Cancel already cancelled order (idempotent, should return cancelled order)
- ✅ Cancel another user's order (should fail with 403)
- ✅ Cancel non-existent order (should fail with 404)
- ✅ Cancel order without authentication (should fail)

**Expected Behavior**:
- Order status changes to `cancelled`
- `cancelled_at` timestamp is set
- Property booking is deleted if order type is `property_booking`

### Phase 5: Mapbox Location Services Tests

#### 5.1 Geocode Endpoint
**Endpoint**: `GET /v1/locations/geocode?address=...`

**Test Cases**:
- ✅ Geocode valid address in Kenya
- ✅ Geocode with country parameter
- ✅ Geocode address outside Kenya (should fail)
- ✅ Geocode invalid/nonexistent address (should fail)
- ✅ Test caching (second request should be faster)

**Sample Request**:
```bash
curl "http://localhost:3000/v1/locations/geocode?address=Westlands, Nairobi"
```

#### 5.2 Reverse Geocode Endpoint
**Endpoint**: `GET /v1/locations/reverse-geocode?lat=...&lng=...`

**Test Cases**:
- ✅ Reverse geocode valid coordinates in Kenya
- ✅ Reverse geocode coordinates outside Kenya (should fail)
- ✅ Reverse geocode invalid coordinates (should fail)
- ✅ Test caching

**Sample Request**:
```bash
curl "http://localhost:3000/v1/locations/reverse-geocode?lat=-1.2634&lng=36.8007"
```

#### 5.3 Distance Calculation Endpoint
**Endpoint**: `GET /v1/locations/distance?fromLat=...&fromLng=...&toLat=...&toLng=...`

**Test Cases**:
- ✅ Calculate distance between two points
- ✅ Calculate distance with invalid coordinates (should fail)
- ✅ Verify distance accuracy (Nairobi to Kisumu ~265km)

**Sample Request**:
```bash
curl "http://localhost:3000/v1/locations/distance?fromLat=-1.2634&fromLng=36.8007&toLat=-0.0917&toLng=34.7680"
```

#### 5.4 Validate Coordinates Endpoint
**Endpoint**: `GET /v1/locations/validate?lat=...&lng=...`

**Test Cases**:
- ✅ Validate coordinates within Kenya
- ✅ Validate coordinates outside Kenya
- ✅ Validate invalid coordinate ranges

**Sample Request**:
```bash
curl "http://localhost:3000/v1/locations/validate?lat=-1.2634&lng=36.8007"
```

#### 5.5 Order Service Integration
**Test Cases**:
- ✅ Create order with coordinates outside Kenya (should fail)
- ✅ Create order with valid Kenya coordinates (should succeed)
- ✅ Verify location validation is enforced

### Phase 6: Integration Tests

#### 5.1 Complete Order Flow
1. Register user
2. Login and get tokens
3. Create cleaning order
4. List orders (verify order appears)
5. Get order by ID
6. Create property booking order
7. Cancel cleaning order
8. List orders (verify cancellation)

#### 5.2 Property Booking Conflict Test
1. Register user
2. Login
3. Create property booking for dates Feb 15-18
4. Try to create another booking for same property, dates Feb 16-20 (should fail)
5. Create booking for different dates Feb 20-22 (should succeed)

#### 5.3 Multi-User Isolation Test
1. Register User 1 and User 2
2. User 1 creates order
3. User 2 tries to access User 1's order (should fail)
4. User 2 creates own order
5. Both users list orders (should only see their own)

## Running Tests

### 1. Setup Environment

```bash
# Start Docker services
docker-compose up -d

# Install dependencies
npm install

# Run migrations
npm run migrate

# Seed test data
npm run seed
```

### 2. Start Development Server

```bash
npm run dev
```

### 3. Run Automated Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

### 4. Manual API Testing

Use the provided test data and scenarios above with:
- **Postman** (import collection if available)
- **curl** commands
- **HTTPie**
- **Thunder Client** (VS Code extension)

### 5. Verify Health Check

```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:00:00.000Z",
  "services": {
    "database": "connected",
    "redis": "connected"
  }
}
```

## Test Data Seed Script

The seed script (`migrations/seed.ts`) will create:
- 4 test users (2 regular, 1 agent, 1 admin)
- 3 test properties (2 available, 1 unavailable)
- Sample orders (optional, for testing retrieval)

## Expected Test Results

### Success Criteria
- ✅ All authentication endpoints return correct status codes
- ✅ All order endpoints return correct status codes
- ✅ Validation errors return 400 with detailed messages
- ✅ Authorization errors return 403
- ✅ Not found errors return 404
- ✅ Property booking conflicts are detected correctly
- ✅ Order cancellation is idempotent
- ✅ Users can only access their own orders
- ✅ Pagination works correctly
- ✅ All database transactions are atomic

### Performance Benchmarks
- Health check: < 50ms
- Authentication: < 200ms
- Order creation: < 300ms
- Order listing (20 items): < 100ms
- Order cancellation: < 200ms

## Troubleshooting

### Database Connection Issues
- Verify Docker containers are running: `docker-compose ps`
- Check database logs: `docker-compose logs postgres`
- Verify DATABASE_URL in `.env` file

### Redis Connection Issues
- Check Redis logs: `docker-compose logs redis`
- Verify REDIS_URL in `.env` file
- Test Redis connection: `redis-cli ping`

### Authentication Issues
- Verify JWT_SECRET is set in `.env`
- Check token expiration times
- Verify refresh token is stored in Redis

### Order Creation Issues
- Verify all required fields are present
- Check location coordinates are valid
- For property bookings, verify property exists and is available

## Next Steps After Testing

1. Review test results and fix any issues
2. Run load tests (if needed)
3. Deploy to staging environment
4. Perform integration testing with frontend
5. Deploy to production
