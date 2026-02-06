import 'api_client.dart';
import 'api_config.dart';
import 'api_exceptions.dart';

/// Location Service
/// Handles location-related API calls using Mapbox
class LocationService {
  final ApiClient _client;

  LocationService({ApiClient? client}) : _client = client ?? apiClient;

  /// Geocode: Convert address to coordinates
  /// Returns: { latitude: double, longitude: double, address: string, ... }
  Future<Map<String, dynamic>> geocode(String address, {String? country}) async {
    try {
      final response = await _client.get(
        ApiConfig.geocodeUrl,
        queryParameters: {
          'query': address,
          if (country != null) 'country': country,
        },
      );

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ApiException('Geocoding failed');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Geocoding failed: ${e.toString()}');
    }
  }

  /// Reverse Geocode: Convert coordinates to address
  /// Returns: { address: string, latitude: double, longitude: double, ... }
  Future<Map<String, dynamic>> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _client.get(
        ApiConfig.reverseGeocodeUrl,
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      );

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ApiException('Reverse geocoding failed');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Reverse geocoding failed: ${e.toString()}');
    }
  }

  /// Validate coordinates
  /// Returns: { valid: bool, message?: string }
  Future<Map<String, dynamic>> validateLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _client.get(
        ApiConfig.validateLocationUrl,
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      );

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw ApiException('Location validation failed');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Location validation failed: ${e.toString()}');
    }
  }

  /// Get location name from coordinates (reverse geocode)
  /// Returns a formatted location string
  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      final result = await reverseGeocode(latitude, longitude);
      
      // API returns: { placeName, address, context: { country, region, district, locality } }
      final placeName = result['placeName'] as String?;
      final address = result['address'] as String?;
      final context = result['context'] as Map<String, dynamic>?;
      
      // Extract location components from context
      final locality = context?['locality'] as String?; // City/town
      final district = context?['district'] as String?; // Area/neighborhood
      final region = context?['region'] as String?; // County/state
      
      // Format: "District, Locality" or "Locality, Region" or "PlaceName"
      if (district != null && locality != null) {
        return '$district, $locality';
      } else if (locality != null && region != null) {
        return '$locality, $region';
      } else if (locality != null) {
        return locality;
      } else if (placeName != null && placeName.isNotEmpty) {
        // Use placeName but try to shorten it (remove country if present)
        final shortened = placeName.split(',').take(2).join(',').trim();
        return shortened.isNotEmpty ? shortened : placeName;
      } else if (address != null && address.isNotEmpty) {
        // Use address but try to shorten it
        final shortened = address.split(',').take(2).join(',').trim();
        return shortened.isNotEmpty ? shortened : address;
      } else {
        return 'Current Location';
      }
    } catch (e) {
      // Fallback to coordinates if API fails
      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }
}

/// Singleton instance
final locationService = LocationService();
