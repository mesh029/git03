/// Enum representing different map service modes
enum MapMode {
  /// Property search and location targeting (Saka Keja)
  properties,
  
  /// Laundry service with pickup location selection (Fresh Keja)
  laundry,
  
  /// House cleaning service (Fresh Keja)
  cleaning,
  
  /// Ride booking with from/to locations (RideX - future)
  rides,
}

/// Property type for Keja service
enum PropertyType {
  /// Bed & Breakfast / Short-term rentals
  bnb,
  
  /// Apartment / Long-term rentals
  apartment,
  
  /// All property types
  all,
}

extension MapModeExtension on MapMode {
  String get title {
    switch (this) {
      case MapMode.properties:
        return 'Location targeting';
      case MapMode.laundry:
        return 'Select pickup location';
      case MapMode.cleaning:
        return 'Select service location';
      case MapMode.rides:
        return 'Book a ride';
    }
  }
}

extension PropertyTypeExtension on PropertyType {
  String get label {
    switch (this) {
      case PropertyType.bnb:
        return 'BNB';
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.all:
        return 'All';
    }
  }
  
  String get description {
    switch (this) {
      case PropertyType.bnb:
        return 'Short-term stays';
      case PropertyType.apartment:
        return 'Long-term rentals';
      case PropertyType.all:
        return 'All properties';
    }
  }
}
