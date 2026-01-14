/// Centralized map configuration
/// Swap map providers by modifying this file only
class MapConfig {
  // Tile provider configuration
  // Using OpenStreetMap - free, no API keys required
  static const String tileProviderUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String attribution = '© OpenStreetMap contributors';
  
  // Alternative: If OpenStreetMap is blocked, use CartoDB
  // static const String tileProviderUrl = 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
  
  // Map settings
  static const double initialZoom = 13.0;
  static const double minZoom = 3.0;
  static const double maxZoom = 18.0;
  
  // User location settings
  static const double userLocationAccuracy = 10.0; // meters
  static const Duration locationUpdateInterval = Duration(seconds: 5);
  
  // Marker settings
  static const double markerSize = 40.0;
  static const double selectedMarkerSize = 50.0;
  
  // Default location (Kisumu, Kenya) - fallback if GPS unavailable
  static const double defaultLatitude = -0.0917;
  static const double defaultLongitude = 34.7680;
  
  // To switch to Mapbox or other providers, change these:
  // static const String tileProviderUrl = 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}';
  // static const String attribution = '© Mapbox';
}
