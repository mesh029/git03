# Step 10: Real-time Tracking - Implementation Plan

## Overview
Implement real-time order tracking system to enable users to track order status updates and service provider locations.

## Business Requirements

### Order Status Tracking

1. **Status Updates**
   - Track order status changes over time
   - History of status transitions
   - Timestamps for each status change
   - Who made the status change (user, admin, system)

2. **Service Provider Tracking** (Future)
   - Real-time location updates
   - Service provider assignment
   - ETA calculations
   - Route tracking

### Features

- **Status History**: Track all status changes
- **Status Updates**: Allow service providers/admins to update order status
- **Tracking Info**: Get current order tracking information
- **Notifications**: Real-time updates (polling initially, WebSocket later)
- **ETAs**: Estimated time of arrival/completion

## Database Schema

### `order_status_history` Table
```sql
CREATE TABLE order_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status VARCHAR(50) NOT NULL,
  updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### `order_tracking` Table (for service provider tracking)
```sql
CREATE TABLE order_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  service_provider_id UUID REFERENCES users(id) ON DELETE SET NULL,
  current_location_latitude DECIMAL(10, 7),
  current_location_longitude DECIMAL(10, 7),
  current_location_label VARCHAR(255),
  estimated_completion_time TIMESTAMP,
  last_updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);
```

## API Endpoints

### User/Service Provider Endpoints

1. **GET /v1/orders/:id/tracking**
   - Get order tracking information
   - Returns: Current status, status history, location (if available), ETA

2. **PATCH /v1/orders/:id/status**
   - Update order status (for service providers/admins)
   - Body: `{ status: 'in_progress' | 'completed' | 'cancelled', notes?: string }`
   - Returns: Updated order with status history

3. **POST /v1/orders/:id/tracking/location**
   - Update service provider location (for service providers)
   - Body: `{ latitude: number, longitude: number, label?: string }`
   - Returns: Updated tracking info

4. **GET /v1/orders/:id/status-history**
   - Get order status history
   - Returns: List of status changes with timestamps

### Admin Endpoints

5. **GET /v1/admin/orders/:id/tracking**
   - Get order tracking (admin view)

6. **PATCH /v1/admin/orders/:id/status**
   - Update order status (admin override)

## Implementation Steps

### 1. Database Migration
- Create `order_status_history` table
- Create `order_tracking` table
- Add indexes for efficient queries
- Add triggers for auto-tracking status changes

### 2. Models & Types
- `OrderStatusHistory` model
- `OrderTracking` model
- `OrderStatus` enum (extend with new statuses)
- `TrackingResponse` interface

### 3. Tracking Service
- `getOrderTracking()` - Get tracking info
- `updateOrderStatus()` - Update status and record history
- `updateServiceProviderLocation()` - Update location
- `getStatusHistory()` - Get status history
- `calculateETA()` - Calculate estimated completion time

### 4. Tracking Controller
- Handle HTTP requests
- Validate input
- Call service methods
- Return formatted responses

### 5. Tracking Routes
- Define all endpoints
- Apply authentication middleware
- Apply service provider/admin middleware where needed
- Apply rate limiting

### 6. Tracking Validators
- Joi schemas for:
  - Update order status
  - Update location
  - Status history queries

### 7. Integration with Orders
- Auto-create tracking record when order is created
- Auto-record status changes
- Link status updates to order

### 8. Tests
- Unit tests for service methods
- Integration tests for all endpoints
- Test status history tracking
- Test location updates

## Order Status Flow

### Extended Statuses
- `pending` - Order created, awaiting assignment
- `assigned` - Service provider assigned
- `in_progress` - Service provider en route or working
- `completed` - Order completed
- `cancelled` - Order cancelled

### Status Transitions
- `pending` → `assigned` → `in_progress` → `completed`
- Any status → `cancelled` (can cancel at any time)

## Business Logic

### Status Updates
- Record who made the change
- Record timestamp
- Record optional notes
- Validate status transitions
- Update order status
- Create history record

### Location Updates
- Update service provider location
- Calculate distance to order location
- Estimate ETA based on distance
- Store location history (optional)

### Tracking Info
- Current status
- Status history
- Current location (if service provider assigned)
- ETA
- Service provider info (if assigned)

## Security Considerations

- Service providers can only update their assigned orders
- Users can only view their own order tracking
- Admins can update any order status
- Location updates require service provider role
- Status transitions validated

## Future Enhancements

- WebSocket for real-time updates
- Push notifications
- Location history tracking
- Route optimization
- Real-time ETA calculations
- Service provider assignment system
- GPS integration

## Testing Strategy

1. **Unit Tests**
   - Service methods
   - Status transition logic
   - ETA calculations
   - Location updates

2. **Integration Tests**
   - All endpoints
   - Status update flows
   - Location update flows
   - Authorization checks
   - Status history tracking

3. **Edge Cases**
   - Invalid status transitions
   - Multiple status updates
   - Location updates without assignment
   - Cancelled orders

## Next Steps

1. Create database migration
2. Extend OrderStatus enum
3. Implement tracking service
4. Create controllers and routes
5. Add validators
6. Write comprehensive tests
7. Integrate with order creation
