# 🔌 API Integration Plan - Flutter App

## 📋 Overview

This document outlines everything needed to integrate the Flutter app with the JuaX API backend. The app currently uses dummy/mock data and needs to be connected to the real API endpoints.

---

## ✅ **COMPLETED**

1. ✅ **Updated Login Screen** - Test users now match seeded API users
   - Changed from dummy users to API seeded users
   - Updated emails and passwords to match database

---

## 🎯 **INTEGRATION CHECKLIST**

### **Phase 1: Setup & Infrastructure** 🔧

#### 1.1 Create API Service Layer
**Priority: HIGH** | **Status: TODO**

**Files to Create:**
- `lib/services/api/api_client.dart` - HTTP client wrapper
- `lib/services/api/api_config.dart` - API base URL and configuration
- `lib/services/api/api_exceptions.dart` - Error handling

**What's Needed:**
```dart
// lib/services/api/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000'; // Change for production
  static const String apiVersion = '/v1';
  static Duration timeout = Duration(seconds: 30);
}

// lib/services/api/api_client.dart
class ApiClient {
  final http.Client _client;
  String? _accessToken;
  
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body);
  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body);
  Future<void> delete(String endpoint);
  void setAccessToken(String token);
  void clearAccessToken();
}
```

**Dependencies:**
- ✅ `http: ^1.1.0` (already in pubspec.yaml)

---

### **Phase 2: Authentication Integration** 🔐

#### 2.1 Auth Service
**Priority: HIGH** | **Status: TODO**

**Files to Create:**
- `lib/services/api/auth_service.dart`

**Endpoints to Integrate:**
- `POST /v1/auth/register` - User registration
- `POST /v1/auth/login` - User login
- `POST /v1/auth/refresh` - Refresh access token
- `POST /v1/auth/logout` - User logout
- `GET /v1/auth/me` - Get current user

**Files to Update:**
- `lib/providers/auth_provider.dart` - Replace dummy login with API calls
- `lib/screens/login_screen.dart` - Handle API errors
- `lib/screens/signup_screen.dart` - Connect to registration endpoint

**Current State:**
- ❌ Uses `DummyUsers` class
- ❌ No password validation
- ❌ No token storage
- ❌ No session management

**Required Changes:**
1. Remove `DummyUsers` class
2. Store JWT tokens securely (use `shared_preferences` or `flutter_secure_storage`)
3. Add token refresh logic
4. Handle API errors (network, validation, auth errors)
5. Update user model to match API response

**API Response Format:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "User Name",
      "phone": "+254712345678",
      "is_admin": false,
      "is_agent": false,
      "created_at": "2024-01-01T00:00:00Z"
    },
    "tokens": {
      "accessToken": "jwt_token",
      "refreshToken": "refresh_token"
    }
  }
}
```

---

### **Phase 3: Properties/Listings Integration** 🏠

#### 3.1 Properties Service
**Priority: HIGH** | **Status: TODO**

**Files to Create:**
- `lib/services/api/property_service.dart`

**Endpoints to Integrate:**
- `GET /v1/properties` - List properties (with filters)
- `GET /v1/properties/:id` - Get property details
- `POST /v1/properties` - Create property (agents only)
- `PATCH /v1/properties/:id` - Update property (agents only)
- `DELETE /v1/properties/:id` - Delete property (agents only)

**Files to Update:**
- `lib/providers/listings_provider.dart` - Replace dummy data with API calls
- `lib/screens/home_screen.dart` - Load featured listings from API
- `lib/screens/map_screen.dart` - Load properties for map markers
- `lib/screens/property_detail_screen.dart` - Load property details from API
- `lib/screens/agent_listing_form_screen.dart` - Submit new listings to API

**Current State:**
- ❌ Uses hardcoded `getFeaturedListings()` method
- ❌ `ListingsProvider` uses local storage only
- ❌ No real-time property updates

**Required Changes:**
1. Replace hardcoded listings with API calls
2. Add pagination support
3. Add filtering (type, location, price range)
4. Handle property images from API
5. Add property creation/editing for agents

**API Response Format:**
```json
{
  "success": true,
  "data": {
    "properties": [
      {
        "id": "uuid",
        "agent_id": "uuid",
        "type": "apartment",
        "title": "Property Title",
        "location_latitude": -1.2921,
        "location_longitude": 36.8219,
        "area_label": "Nairobi, Kenya",
        "is_available": true,
        "price_label": "KES 15,000/night",
        "rating": 4.5,
        "traction": 120,
        "amenities": ["WiFi", "Parking"],
        "house_rules": ["No smoking"],
        "images": ["url1", "url2"]
      }
    ],
    "count": 10
  }
}
```

---

### **Phase 4: Orders Integration** 📦

#### 4.1 Orders Service
**Priority: HIGH** | **Status: TODO**

**Files to Create:**
- `lib/services/api/order_service.dart`

**Endpoints to Integrate:**
- `POST /v1/orders` - Create order
- `GET /v1/orders` - List user orders
- `GET /v1/orders/:id` - Get order details
- `GET /v1/orders/:id/tracking` - Get order tracking
- `PATCH /v1/orders/:id/cancel` - Cancel order
- `PATCH /v1/orders/:id/status` - Update order status (service providers)

**Files to Update:**
- `lib/providers/order_provider.dart` - Replace dummy orders with API calls
- `lib/screens/orders_screen.dart` - Load orders from API
- `lib/screens/fresh_keja_service_screen.dart` - Submit orders to API
- `lib/screens/admin_orders_screen.dart` - Load all orders (admin)

**Current State:**
- ❌ Uses dummy orders list
- ❌ No real order creation
- ❌ No order tracking
- ❌ No status updates

**Required Changes:**
1. Replace dummy orders with API calls
2. Add order creation with location validation
3. Add real-time order tracking (WebSocket integration)
4. Add order status updates
5. Handle order cancellation

**API Response Format:**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "uuid",
        "owner_id": "uuid",
        "type": "cleaning",
        "status": "pending",
        "location": {
          "latitude": -1.2921,
          "longitude": 36.8219,
          "label": "Nairobi, Kenya"
        },
        "details": {
          "service": "deepCleaning",
          "rooms": 3
        },
        "created_at": "2024-01-01T00:00:00Z"
      }
    ],
    "count": 5
  }
}
```

---

### **Phase 5: Location Services Integration** 📍

#### 5.1 Location Service
**Priority: MEDIUM** | **Status: TODO**

**Files to Create:**
- `lib/services/api/location_service.dart`

**Endpoints to Integrate:**
- `GET /v1/locations/geocode?address=...` - Address to coordinates
- `GET /v1/locations/reverse-geocode?lat=...&lng=...` - Coordinates to address
- `GET /v1/locations/validate?lat=...&lng=...` - Validate coordinates
- `GET /v1/locations/distance?fromLat=...&fromLng=...&toLat=...&toLng=...` - Calculate distance

**Files to Update:**
- `lib/services/map/location_name_service.dart` - Use API reverse geocoding
- `lib/screens/location_picker_screen.dart` - Use API for address lookup
- `lib/screens/map_screen.dart` - Validate selected locations

**Current State:**
- ❌ Uses hardcoded location names
- ❌ No real geocoding
- ❌ No location validation

**Required Changes:**
1. Replace hardcoded location names with API reverse geocoding
2. Add address search using geocoding API
3. Validate locations are within Kenya
4. Calculate distances for service providers

---

### **Phase 6: Messages Integration** 💬

#### 6.1 Messages Service
**Priority: MEDIUM** | **Status: TODO**

**Files to Create:**
- `lib/services/api/message_service.dart`

**Endpoints to Integrate:**
- `GET /v1/messages` - List conversations
- `GET /v1/messages/:conversationId` - Get messages in conversation
- `POST /v1/messages` - Send message
- `PATCH /v1/messages/:id/read` - Mark as read

**Files to Update:**
- `lib/providers/messages_provider.dart` - Replace dummy messages with API calls
- `lib/screens/messages_screen.dart` - Load messages from API

**Current State:**
- ❌ Uses dummy messages
- ❌ No real-time messaging
- ❌ No message persistence

**Required Changes:**
1. Replace dummy messages with API calls
2. Add WebSocket for real-time messaging (optional)
3. Add message read status
4. Handle order-related conversations

---

### **Phase 7: Admin & Agent Features** 👨‍💼

#### 7.1 Admin Service
**Priority: LOW** | **Status: TODO**

**Endpoints to Integrate:**
- `GET /v1/admin/users` - List all users
- `GET /v1/admin/orders` - List all orders
- `GET /v1/admin/properties` - List all properties
- `GET /v1/admin/stats` - Platform statistics

**Files to Update:**
- `lib/screens/admin_orders_screen.dart` - Load admin data from API

#### 7.2 Agent Service
**Priority: MEDIUM** | **Status: TODO**

**Endpoints to Integrate:**
- Property management (already covered in Phase 3)
- Order management for assigned orders

**Files to Update:**
- `lib/screens/agent_dashboard_screen.dart` - Load agent data from API

---

## 🔧 **TECHNICAL REQUIREMENTS**

### **Dependencies Needed**

Already in `pubspec.yaml`:
- ✅ `http: ^1.1.0` - HTTP client
- ✅ `shared_preferences: ^2.2.3` - Token storage

**Consider Adding:**
- `flutter_secure_storage: ^9.0.0` - Secure token storage (recommended)
- `dio: ^5.4.0` - Advanced HTTP client (optional, better than http package)
- `web_socket_channel: ^2.4.0` - Real-time updates (optional)

### **Environment Configuration**

Create `lib/config/api_config.dart`:
```dart
class ApiConfig {
  // Development
  static const String baseUrl = 'http://localhost:3000';
  
  // Production (update when deploying)
  // static const String baseUrl = 'https://api.juax.com';
  
  static const String apiVersion = '/v1';
  static Duration timeout = Duration(seconds: 30);
}
```

### **Error Handling**

Create comprehensive error handling:
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  
  ApiException(this.message, {this.statusCode, this.data});
  
  factory ApiException.fromResponse(http.Response response) {
    // Parse API error response
  }
}
```

### **Token Management**

Store tokens securely:
```dart
class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  static Future<void> saveTokens(String accessToken, String refreshToken);
  static Future<String?> getAccessToken();
  static Future<String?> getRefreshToken();
  static Future<void> clearTokens();
}
```

---

## 📝 **IMPLEMENTATION ORDER**

### **Recommended Sequence:**

1. **Phase 1** - Setup API infrastructure (ApiClient, config, error handling)
2. **Phase 2** - Authentication (most critical, unlocks other features)
3. **Phase 5** - Location services (needed for orders/properties)
4. **Phase 3** - Properties (core feature)
5. **Phase 4** - Orders (depends on auth + location)
6. **Phase 6** - Messages (nice to have)
7. **Phase 7** - Admin/Agent features (specialized)

---

## 🧪 **TESTING STRATEGY**

### **Test Users (Already Seeded)**

**Customers:**
- `customer1@juax.test` / `Test123!@#` - Freemium user
- `customer2@juax.test` / `Test123!@#` - Premium user
- `freemium@juax.test` / `Test123!@#` - Freemium user

**Agents:**
- `agent1@juax.test` / `Agent123!@#` - Property agent

**Admins:**
- `admin@juax.test` / `Admin123!@#` - Platform admin

**Combined:**
- `superuser@juax.test` / `Super123!@#` - Admin + Agent

### **Testing Checklist**

- [ ] Login with seeded users
- [ ] Register new user
- [ ] Load properties from API
- [ ] Create order with location
- [ ] View order tracking
- [ ] Cancel order
- [ ] Create property (as agent)
- [ ] Update property (as agent)
- [ ] Load messages
- [ ] Send message

---

## 🚨 **IMPORTANT NOTES**

1. **API Base URL**: Currently set to `localhost:3000`. Update for production.

2. **CORS**: Ensure API allows requests from Flutter app origin.

3. **Token Storage**: Use secure storage for production (flutter_secure_storage).

4. **Error Handling**: Implement comprehensive error handling for:
   - Network errors
   - API errors (400, 401, 403, 404, 500)
   - Timeout errors
   - JSON parsing errors

5. **Offline Support**: Consider caching for offline functionality (future enhancement).

6. **Loading States**: Show loading indicators during API calls.

7. **Error Messages**: Display user-friendly error messages.

---

## 📚 **API DOCUMENTATION**

All API endpoints are documented in:
- `api/README.md` - General API documentation
- `api/TEST_RESULTS.md` - Test examples
- `api/LOCATION_PICKER_CONFIRMATION.md` - Location endpoints

**Base URL**: `http://localhost:3000/v1`

**Authentication**: Bearer token in `Authorization` header:
```
Authorization: Bearer {access_token}
```

---

## ✅ **NEXT STEPS**

1. **Start with Phase 1** - Create API service infrastructure
2. **Then Phase 2** - Integrate authentication (most critical)
3. **Test thoroughly** with seeded users
4. **Iterate** through remaining phases

---

**Last Updated**: After reviewing app structure and API endpoints
**Status**: Ready for implementation
