# API Service Layer

This directory contains the API service layer for communicating with the JuaX backend API.

## Files

- **`api_config.dart`** - API configuration (base URLs, endpoints)
- **`api_client.dart`** - HTTP client wrapper for making API requests
- **`api_exceptions.dart`** - Custom exception classes for error handling
- **`token_storage.dart`** - Token storage service for JWT tokens

## Usage

### Basic Example

```dart
import 'package:juax/services/api/api_client.dart';
import 'package:juax/services/api/api_config.dart';
import 'package:juax/services/api/api_exceptions.dart';

// Get singleton instance
final client = apiClient;

// Load stored token (if available)
await client.loadAccessToken();

// Make a GET request
try {
  final response = await client.get(ApiConfig.propertiesUrl);
  if (response['success'] == true) {
    final properties = response['data']['properties'];
    // Use properties...
  }
} on UnauthorizedException {
  // Handle unauthorized error
} on NetworkException {
  // Handle network error
} on ApiException catch (e) {
  // Handle other API errors
  print('API Error: ${e.message}');
}
```

### Authenticated Request

```dart
// Set access token (usually done after login)
client.setAccessToken('your_access_token');

// Make authenticated request
final response = await client.get(ApiConfig.ordersUrl);
```

### POST Request

```dart
try {
  final response = await client.post(
    ApiConfig.loginUrl,
    body: {
      'email': 'user@example.com',
      'password': 'password123',
    },
  );
  
  if (response['success'] == true) {
    final tokens = response['data']['tokens'];
    // Save tokens...
  }
} on ValidationException catch (e) {
  // Handle validation errors
  print('Validation error: ${e.message}');
}
```

### Error Handling

```dart
try {
  final response = await client.get(ApiConfig.propertiesUrl);
} on UnauthorizedException {
  // Token expired or invalid - redirect to login
} on NotFoundException {
  // Resource not found
} on ValidationException catch (e) {
  // Validation errors (422)
  print('Validation errors: ${e.data}');
} on NetworkException {
  // No internet connection
  print('Please check your internet connection');
} on TimeoutException {
  // Request timed out
  print('Request took too long');
} on ApiException catch (e) {
  // Other API errors
  print('Error: ${e.message} (${e.statusCode})');
}
```

### Token Management

```dart
import 'package:juax/services/api/token_storage.dart';

// Save tokens after login
await TokenStorage.saveTokens(accessToken, refreshToken);

// Get tokens
final accessToken = await TokenStorage.getAccessToken();
final refreshToken = await TokenStorage.getRefreshToken();

// Check if authenticated
final isAuth = await TokenStorage.isAuthenticated();

// Clear tokens on logout
await TokenStorage.clearTokens();
```

## Configuration

Update `api_config.dart` for different environments:

```dart
// Development
static const String baseUrl = 'http://localhost:3000';

// Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// iOS Simulator
static const String baseUrl = 'http://localhost:3000';

// Physical Device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.100:3000';

// Production
static const String baseUrl = 'https://api.juax.com';
```

## Next Steps

1. ✅ Phase 1 Complete - API infrastructure setup
2. ⏭️ Phase 2 - Create auth service using this client
3. ⏭️ Phase 3 - Create property service
4. ⏭️ Phase 4 - Create order service
5. ⏭️ Phase 5 - Create location service
