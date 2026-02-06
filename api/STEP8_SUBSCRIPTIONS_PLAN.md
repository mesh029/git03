# Step 8: Subscriptions & Membership Management - Implementation Plan

## Overview
Implement comprehensive subscription and membership management system to support freemium and premium tiers, enabling access control and revenue generation.

## Business Requirements

### Subscription Tiers

1. **Freemium (Free)**
   - Basic access to platform
   - Limited order creation (e.g., 3 orders/month)
   - Basic property listings (if agent)
   - Standard support

2. **Premium**
   - Unlimited orders
   - Priority support
   - Advanced property features (if agent)
   - Analytics dashboard access

3. **Service-Specific Plans**
   - Cleaning-only subscription
   - Laundry-only subscription
   - Property booking subscription
   - Combined service plans

### Subscription Features

- **Status**: `active`, `expired`, `cancelled`, `trial`
- **Billing**: Monthly or annual
- **Auto-renewal**: Enabled/disabled
- **Trial period**: 7-14 days for premium tiers
- **Grace period**: 7 days after expiration before access is revoked

## Database Schema

### `subscriptions` Table
```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  tier VARCHAR(50) NOT NULL CHECK (tier IN ('freemium', 'premium', 'cleaning', 'laundry', 'property_booking', 'combined')),
  status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled', 'trial')),
  billing_period VARCHAR(20) NOT NULL CHECK (billing_period IN ('monthly', 'annual')),
  auto_renew BOOLEAN DEFAULT true,
  trial_ends_at TIMESTAMP,
  current_period_start TIMESTAMP NOT NULL,
  current_period_end TIMESTAMP NOT NULL,
  cancelled_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### `subscription_features` Table (for feature access tracking)
```sql
CREATE TABLE subscription_features (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
  feature VARCHAR(100) NOT NULL,
  enabled BOOLEAN DEFAULT true,
  limit_value INTEGER, -- e.g., max orders per month
  created_at TIMESTAMP DEFAULT NOW()
);
```

## API Endpoints

### Public/User Endpoints

1. **GET /v1/subscriptions**
   - List all available subscription tiers
   - Returns: Available tiers with pricing and features

2. **GET /v1/subscriptions/current**
   - Get user's current subscription
   - Requires: Authentication
   - Returns: Current subscription details, status, features

3. **POST /v1/subscriptions/upgrade**
   - Upgrade to a higher tier
   - Requires: Authentication
   - Body: `{ tier: 'premium', billingPeriod: 'monthly' }`
   - Returns: Updated subscription

4. **POST /v1/subscriptions/downgrade**
   - Downgrade to a lower tier
   - Requires: Authentication
   - Body: `{ tier: 'freemium' }`
   - Returns: Updated subscription

5. **POST /v1/subscriptions/cancel**
   - Cancel current subscription
   - Requires: Authentication
   - Returns: Cancelled subscription (access until period end)

6. **GET /v1/subscriptions/access**
   - Check feature access for current user
   - Requires: Authentication
   - Query: `?feature=unlimited_orders`
   - Returns: Access status and limits

### Admin Endpoints

7. **GET /v1/admin/subscriptions**
   - List all subscriptions (with filters)
   - Requires: Admin authentication
   - Query: `?status=active&tier=premium`

8. **GET /v1/admin/subscriptions/:id**
   - Get subscription details
   - Requires: Admin authentication

9. **PATCH /v1/admin/subscriptions/:id/status**
   - Update subscription status (admin override)
   - Requires: Admin authentication

## Implementation Steps

### 1. Database Migration
- Create `subscriptions` table
- Create `subscription_features` table
- Add indexes for efficient queries
- Create seed data for default subscription tiers

### 2. Models & Types
- `Subscription` model
- `SubscriptionTier` enum
- `SubscriptionStatus` enum
- `BillingPeriod` enum
- `SubscriptionFeature` model

### 3. Subscription Service
- `getAvailableSubscriptions()` - List all tiers
- `getCurrentSubscription(userId)` - Get user's active subscription
- `upgradeSubscription(userId, tier, billingPeriod)` - Upgrade subscription
- `downgradeSubscription(userId, tier)` - Downgrade subscription
- `cancelSubscription(userId)` - Cancel subscription
- `checkFeatureAccess(userId, feature)` - Check if user has access to feature
- `updateSubscriptionStatus(subscriptionId, status)` - Admin override
- `expireSubscriptions()` - Background job to expire subscriptions

### 4. Subscription Controller
- Handle HTTP requests
- Validate input
- Call service methods
- Return formatted responses

### 5. Subscription Routes
- Define all endpoints
- Apply authentication middleware
- Apply admin middleware where needed
- Apply rate limiting

### 6. Subscription Validators
- Joi schemas for:
  - Upgrade subscription
  - Downgrade subscription
  - Cancel subscription
  - Admin status update

### 7. Subscription Middleware
- `requireSubscription(tier)` - Require minimum tier
- `requireFeature(feature)` - Require specific feature access
- `checkSubscriptionLimits()` - Check usage against limits

### 8. Integration with Existing Features
- Update order creation to check subscription limits
- Update property creation to check agent subscription
- Add subscription checks to relevant endpoints

### 9. Tests
- Unit tests for service methods
- Integration tests for all endpoints
- Test subscription limits enforcement
- Test upgrade/downgrade flows

## Subscription Tiers Configuration

### Freemium (Default)
- Max orders per month: 3
- Basic property listings: Yes
- Support: Standard
- Analytics: No

### Premium
- Max orders per month: Unlimited
- Advanced property features: Yes
- Support: Priority
- Analytics: Yes
- Price: KES 999/month or KES 9,999/year

### Service-Specific
- Cleaning: Unlimited cleaning orders
- Laundry: Unlimited laundry orders
- Property Booking: Unlimited property bookings
- Combined: All services unlimited

## Access Control Logic

1. **Order Creation**
   - Check if user has active subscription
   - Check order count for current period
   - Enforce limits based on tier

2. **Property Management**
   - Agents need at least freemium tier
   - Premium agents get advanced features

3. **Feature Access**
   - Check subscription status
   - Check feature-specific limits
   - Return access status

## Background Jobs (Future)

- Daily job to expire subscriptions
- Daily job to send renewal reminders
- Daily job to revoke access after grace period

## Security Considerations

- Users can only manage their own subscriptions
- Admins can override any subscription
- Subscription status changes are logged
- Payment integration (future - Stripe/M-Pesa)

## Testing Strategy

1. **Unit Tests**
   - Service methods
   - Subscription logic
   - Feature access checks

2. **Integration Tests**
   - All endpoints
   - Upgrade/downgrade flows
   - Access control enforcement
   - Limit enforcement

3. **Edge Cases**
   - Expired subscriptions
   - Cancelled subscriptions
   - Trial period expiration
   - Concurrent subscription changes

## Next Steps

1. Create database migration
2. Implement models and types
3. Build subscription service
4. Create controllers and routes
5. Add middleware for access control
6. Write comprehensive tests
7. Integrate with existing endpoints
