/// API Configuration
/// Centralized configuration for API endpoints and settings
class ApiConfig {
  // Base URL - Update for production
  // For Android emulator, use: http://10.0.2.2:3000
  // For iOS simulator, use: http://localhost:3000
  // For physical device, use your computer's IP: http://192.168.x.x:3000
  static const String baseUrl = 'http://localhost:3000';
  
  // API version prefix
  static const String apiVersion = '/v1';
  
  // Request timeout
  static const Duration timeout = Duration(seconds: 30);
  
  // Get full API URL
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  // Health check endpoint
  static String get healthCheckUrl => '$baseUrl/health';
  
  // Auth endpoints
  static String get registerUrl => '$apiBaseUrl/auth/register';
  static String get loginUrl => '$apiBaseUrl/auth/login';
  static String get refreshTokenUrl => '$apiBaseUrl/auth/refresh';
  static String get logoutUrl => '$apiBaseUrl/auth/logout';
  static String get meUrl => '$apiBaseUrl/auth/me';
  
  // Order endpoints
  static String get ordersUrl => '$apiBaseUrl/orders';
  static String orderUrl(String id) => '$ordersUrl/$id';
  static String orderCancelUrl(String id) => '$ordersUrl/$id/cancel';
  static String orderTrackingUrl(String id) => '$ordersUrl/$id/tracking';
  
  // Property endpoints
  static String get propertiesUrl => '$apiBaseUrl/properties';
  static String propertyUrl(String id) => '$propertiesUrl/$id';
  
  // Location endpoints
  static String get locationsUrl => '$apiBaseUrl/locations';
  static String get geocodeUrl => '$locationsUrl/geocode';
  static String get reverseGeocodeUrl => '$locationsUrl/reverse-geocode';
  static String get validateLocationUrl => '$locationsUrl/validate';
  static String get distanceUrl => '$locationsUrl/distance';
  
  // Message endpoints
  static String get messagesUrl => '$apiBaseUrl/messages';
  static String messageUrl(String conversationId) => '$messagesUrl/$conversationId';
  static String markMessageReadUrl(String messageId) => '$messagesUrl/$messageId/read';
  
  // Admin endpoints
  static String get adminUsersUrl => '$apiBaseUrl/admin/users';
  static String adminUserUrl(String id) => '$adminUsersUrl/$id';
  static String get adminOrdersUrl => '$apiBaseUrl/admin/orders';
  static String get adminPropertiesUrl => '$apiBaseUrl/admin/properties';
  static String get adminStatsUrl => '$apiBaseUrl/admin/stats';
  
  // Service location endpoints
  static String get serviceLocationsUrl => '$apiBaseUrl/service-locations';
  static String serviceLocationUrl(String id) => '$serviceLocationsUrl/$id';
  static String get nearbyServiceLocationsUrl => '$serviceLocationsUrl/nearby';
  
  // Log endpoints
  static String get uiLogsUrl => '$apiBaseUrl/logs/ui';
  static String get uiLogsViewerUrl => '$baseUrl/v1/logs/ui/viewer';
}
