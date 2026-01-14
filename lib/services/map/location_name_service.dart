import 'package:geolocator/geolocator.dart';

/// Service for getting location names from coordinates
/// Uses coordinate-based detection for major Kenyan cities/towns
class LocationNameService {
  // Major Kenyan cities/towns with their coordinates
  static const List<Map<String, dynamic>> _kenyanLocations = [
    {'name': 'Nairobi', 'lat': -1.2921, 'lon': 36.8219},
    {'name': 'Kisumu', 'lat': -0.0917, 'lon': 34.7680},
    {'name': 'Mombasa', 'lat': -4.0435, 'lon': 39.6682},
    {'name': 'Nakuru', 'lat': -0.3031, 'lon': 36.0800},
    {'name': 'Eldoret', 'lat': 0.5143, 'lon': 35.2698},
    {'name': 'Thika', 'lat': -1.0333, 'lon': 37.0694},
    {'name': 'Malindi', 'lat': -3.2175, 'lon': 40.1169},
    {'name': 'Kitale', 'lat': 1.0167, 'lon': 35.0000},
    {'name': 'Garissa', 'lat': -0.4532, 'lon': 39.6464},
    {'name': 'Kakamega', 'lat': 0.2833, 'lon': 34.7500},
    {'name': 'Kisii', 'lat': -0.6833, 'lon': 34.7667},
    {'name': 'Meru', 'lat': 0.0500, 'lon': 37.6500},
    {'name': 'Nyeri', 'lat': -0.4167, 'lon': 36.9500},
    {'name': 'Machakos', 'lat': -1.5167, 'lon': 37.2667},
    {'name': 'Embu', 'lat': -0.5333, 'lon': 37.4500},
    {'name': 'Lamu', 'lat': -2.2694, 'lon': 40.9020},
    {'name': 'Busia', 'lat': 0.4667, 'lon': 34.0833},
    {'name': 'Homa Bay', 'lat': -0.5167, 'lon': 34.4500},
    {'name': 'Kericho', 'lat': -0.3667, 'lon': 35.2833},
    {'name': 'Bungoma', 'lat': 0.5667, 'lon': 34.5667},
  ];

  /// Get the nearest location name from coordinates
  static String getLocationName(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return 'Getting location...';
    }

    // Check if in Kisumu area first (for detailed sub-locations)
    if (_isInKisumuArea(latitude, longitude)) {
      return _getKisumuSubLocation(latitude, longitude);
    }

    // Find nearest major city/town
    String nearestLocation = 'Current Location';
    double minDistance = double.infinity;

    for (final location in _kenyanLocations) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        location['lat'] as double,
        location['lon'] as double,
      ) / 1000; // Convert to km

      // If within 30km of a major city, use that city name
      if (distance < 30 && distance < minDistance) {
        minDistance = distance;
        nearestLocation = location['name'] as String;
      }
    }

    // If not near any major city, try to determine region
    if (minDistance == double.infinity) {
      return _getRegionName(latitude, longitude);
    }

    return nearestLocation;
  }

  /// Check if coordinates are in Kisumu area
  static bool _isInKisumuArea(double latitude, double longitude) {
    const kisumuLat = -0.0917;
    const kisumuLon = 34.7680;
    const radiusKm = 50.0;

    final distance = Geolocator.distanceBetween(
      latitude,
      longitude,
      kisumuLat,
      kisumuLon,
    ) / 1000;

    return distance <= radiusKm;
  }

  /// Get specific sub-location within Kisumu
  static String _getKisumuSubLocation(double latitude, double longitude) {
    // Milimani area
    if (latitude > -0.085 && longitude > 34.77) {
      return 'Kisumu – Milimani';
    }
    // Nyalenda area
    else if (latitude > -0.090 && longitude < 34.765) {
      return 'Kisumu – Nyalenda';
    }
    // Town Center
    else if (latitude > -0.095 && latitude < -0.088 && 
             longitude > 34.765 && longitude < 34.770) {
      return 'Kisumu – Town Center';
    }
    // Kondele area
    else if (latitude < -0.095 && longitude > 34.768) {
      return 'Kisumu – Kondele';
    }
    // Other Kisumu areas
    else {
      return 'Kisumu';
    }
  }

  /// Get region name based on coordinates (for areas far from major cities)
  static String _getRegionName(double latitude, double longitude) {
    // Determine region based on coordinates
    if (latitude > 1.0) {
      return 'Northern Kenya';
    } else if (latitude < -2.0) {
      return 'Coastal Region';
    } else if (longitude < 35.0) {
      return 'Western Kenya';
    } else if (longitude > 37.0) {
      return 'Eastern Kenya';
    } else if (latitude > 0.5) {
      return 'Rift Valley';
    } else if (latitude < -0.5) {
      return 'Central Kenya';
    } else {
      return 'Kenya';
    }
  }

  /// Check if user is in Kisumu service area
  static bool isInKisumuArea(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    return _isInKisumuArea(latitude, longitude);
  }
}
