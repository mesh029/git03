/// Enum representing different map service modes
enum MapMode {
  /// Property search and location targeting (Keja by JuaX)
  properties,
  
  /// Laundry service with pickup location selection (Fresh Keja)
  laundry,
  
  /// Ride booking with from/to locations (RideX - future)
  rides,
}

extension MapModeExtension on MapMode {
  String get title {
    switch (this) {
      case MapMode.properties:
        return 'Location targeting';
      case MapMode.laundry:
        return 'Select pickup location';
      case MapMode.rides:
        return 'Book a ride';
    }
  }
}
