# Step 6: Property Listings Management API

## Overview
Implement complete CRUD (Create, Read, Update, Delete) operations for property listings, allowing agents to manage their properties.

## What's Needed

### 1. **Property Service** (`src/services/propertyService.ts`)
- Create property listing
- Get property by ID
- List properties (with filters: available, type, agent)
- Update property listing
- Delete property listing
- Toggle availability
- Search properties by location/area

### 2. **Property Controller** (`src/controllers/propertyController.ts`)
- `POST /v1/properties` - Create property (Agent only)
- `GET /v1/properties` - List properties (Public, filtered by availability)
- `GET /v1/properties/:id` - Get single property (Public)
- `PATCH /v1/properties/:id` - Update property (Agent owner or Admin)
- `DELETE /v1/properties/:id` - Delete property (Agent owner or Admin)
- `PATCH /v1/properties/:id/availability` - Toggle availability (Agent owner)

### 3. **Property Validators** (`src/validators/propertyValidator.ts`)
- Create property schema
- Update property schema
- Query filters schema

### 4. **Property Routes** (`src/routes/propertyRoutes.ts`)
- Public routes (GET endpoints)
- Protected routes (POST, PATCH, DELETE) - Agent/Admin only
- Rate limiting

### 5. **Integration Points**
- Mapbox integration for location validation
- Agent authorization checks
- Property availability filtering

## Implementation Steps

1. **Create Property Service**
   - CRUD operations
   - Efficient queries with indexes
   - Location validation (Kenya bounds)
   - Availability filtering

2. **Create Property Controller**
   - Handle HTTP requests
   - Parse and validate inputs
   - Call service layer
   - Return appropriate responses

3. **Create Property Validators**
   - Joi schemas for validation
   - Type-specific validation (apartment vs bnb)

4. **Create Property Routes**
   - Public GET endpoints
   - Protected POST/PATCH/DELETE endpoints
   - Agent authorization middleware

5. **Write Tests**
   - Unit tests for service
   - Integration tests for endpoints
   - Authorization tests

6. **Update Documentation**
   - API endpoint documentation
   - Request/response examples

## API Endpoints

### Public Endpoints
- `GET /v1/properties` - List available properties
- `GET /v1/properties/:id` - Get property details

### Agent Endpoints (Requires Authentication)
- `POST /v1/properties` - Create new property
- `PATCH /v1/properties/:id` - Update property (own properties only)
- `DELETE /v1/properties/:id` - Delete property (own properties only)
- `PATCH /v1/properties/:id/availability` - Toggle availability

### Admin Endpoints
- All agent endpoints (can manage any property)
- `GET /v1/properties/all` - List all properties (including unavailable)

## Features

### Property Creation
- Agent can create apartment or bnb listings
- Location validation (Kenya bounds)
- Required fields: type, title, location, area_label
- Optional fields: amenities, house_rules, images, price_label, rating, traction

### Property Listing
- Public users see only available properties
- Filter by type (apartment, bnb)
- Filter by area/location
- Pagination support

### Property Updates
- Agents can update their own properties
- Admins can update any property
- Location updates validated

### Property Deletion
- Soft delete (set is_available = false) or hard delete
- Check for existing bookings before deletion
- Cascade delete property_bookings

## Database Considerations

- Use existing `properties` table
- Indexes already created:
  - `idx_properties_agent_id`
  - `idx_properties_available`
  - `idx_properties_type`
  - `idx_properties_location`

## Security

- Agent authorization (can only manage own properties)
- Admin authorization (can manage all properties)
- Input validation (Joi schemas)
- SQL injection prevention (parameterized queries)
- Rate limiting

## Testing Requirements

- Create property as agent
- List properties (public)
- Update property (own vs others)
- Delete property (with bookings vs without)
- Toggle availability
- Location validation
- Authorization checks

---

## Ready to Proceed?

**What I'll deliver:**
- ✅ Complete property CRUD operations
- ✅ Agent authorization
- ✅ Public listing with filters
- ✅ Location validation
- ✅ Comprehensive tests
- ✅ API documentation

Let me know if you want to proceed! 🚀
