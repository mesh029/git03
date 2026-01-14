import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling location permissions and GPS data
class LocationService {
  /// Request location permissions
  static Future<bool> requestPermission() async {
    // Check current status first
    final currentStatus = await Permission.location.status;
    
    if (currentStatus.isGranted) {
      return true;
    }
    
    if (currentStatus.isDenied) {
      // Request permission - this shows the system dialog
      final status = await Permission.location.request();
      return status.isGranted;
    }
    
    if (currentStatus.isPermanentlyDenied) {
      // Permission was permanently denied - user needs to go to settings
      // Open app settings
      await openAppSettings();
      return false;
    }
    
    // Request permission
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location permission is granted
  static Future<bool> hasPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Get current user location with multiple fallback strategies
  static Future<Position?> getCurrentLocation() async {
    try {
      // First, check and request permission if needed
      final hasPermission = await LocationService.hasPermission();
      if (!hasPermission) {
        // Request permission - this will show the system dialog
        final granted = await requestPermission();
        if (!granted) {
          // Try to get last known location even without permission
          return await _getLastKnownPosition();
        }
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to get last known position even if GPS is disabled
        return await _getLastKnownPosition();
      }

      // Strategy 1: Try high accuracy first
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        // Strategy 2: If high accuracy fails, try medium accuracy
        try {
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (e2) {
          // Strategy 3: If medium fails, try low accuracy
          try {
            return await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 10),
              forceAndroidLocationManager: false,
            );
          } catch (e3) {
            // Strategy 4: Get last known position as fallback
            return await _getLastKnownPosition();
          }
        }
      }
    } catch (e) {
      // Final fallback: try to get last known position
      return await _getLastKnownPosition();
    }
  }

  /// Get last known position (cached location)
  static Future<Position?> _getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  /// Stream of location updates
  static Stream<Position>? getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    );
  }

  /// Calculate distance between two coordinates (in meters)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
