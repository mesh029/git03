# API Integration Tests

This directory contains integration tests for the JuaX API endpoints.

## Test Structure

- `setup.ts` - Test infrastructure setup (database, Redis, app)
- `helpers.ts` - Test helper functions (create users, properties, orders)
- `jest.setup.ts` - Jest configuration and environment setup
- `integration/` - Integration test files for each endpoint group
  - `auth.test.ts` - Authentication endpoints
  - `orders.test.ts` - Order management endpoints
  - `locations.test.ts` - Location/Mapbox endpoints
  - `properties.test.ts` - Property management endpoints
  - `admin.test.ts` - Admin endpoints

## Prerequisites

1. **Test Database**: Create a test database (separate from development)
   ```sql
   CREATE DATABASE juax_test;
   ```

2. **Test Redis**: Use Redis DB 1 for tests (or configure TEST_REDIS_URL)

3. **Environment Variables**: Set test environment variables:
   ```bash
   export TEST_DATABASE_URL="postgresql://juax:juax_dev@localhost:5432/juax_test"
   export TEST_REDIS_URL="redis://localhost:6379/1"
   export JWT_SECRET="test-secret-key"
   export MAPBOX_ACCESS_TOKEN="your-mapbox-token"  # Optional for location tests
   ```

## Running Tests

### Run all tests (fails fast on first error)
```bash
npm test
```

### Run specific test suite
```bash
npm run test:admin      # Admin endpoints only
npm run test:auth       # Auth endpoints only
npm run test:orders     # Order endpoints only
npm run test:properties # Property endpoints only
npm run test:locations  # Location endpoints only
```

### Run tests in watch mode
```bash
npm run test:watch
```

### Run tests with coverage
```bash
npm run test:coverage
```

### Run only integration tests
```bash
npm run test:integration
```

### Run only unit tests
```bash
npm run test:unit
```

## Test Configuration

Tests are configured to **fail fast**:
- `--bail=1` - Stops on first failure
- `--maxWorkers=1` - Runs tests sequentially for better error isolation
- `testTimeout: 10000` - 10 second timeout per test
- `forceExit: true` - Forces exit after tests complete
- `detectOpenHandles: true` - Detects hanging connections

## Test Setup

Before running tests:

1. **Start Docker services** (PostgreSQL and Redis):
   ```bash
   docker-compose up -d
   ```

2. **Create test database** (if not exists):
   ```bash
   npx ts-node tests/setup-db.ts
   ```

3. **Run migrations** on test database:
   ```bash
   DATABASE_URL=$TEST_DATABASE_URL npm run migrate
   ```

4. **Run tests**:
   ```bash
   npm test
   ```

## Test Coverage

The tests cover:

- ✅ Authentication (register, login, refresh, logout, get current user)
- ✅ Order creation (cleaning, laundry, property booking)
- ✅ Order retrieval (list, get by ID, filtering, pagination)
- ✅ Order cancellation
- ✅ Location services (geocode, reverse geocode, distance, validate)
- ✅ Property management (CRUD operations)
- ✅ Admin endpoints (user management, order management, statistics)

## Notes

- Tests use a separate test database (`juax_test`) to avoid affecting development data
- Tests clean up data after each test suite
- Redis DB 1 is used for tests to avoid conflicts
- All tests require valid database and Redis connections
- Tests fail fast on first error for quicker debugging
