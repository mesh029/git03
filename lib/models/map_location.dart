import 'package:latlong2/latlong.dart';

/// Represents a location on the map
class MapLocation {
  final double latitude;
  final double longitude;
  final String? id;
  final String? name;
  final MapLocationType type;

  const MapLocation({
    required this.latitude,
    required this.longitude,
    this.id,
    this.name,
    required this.type,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'id': id,
        'name': name,
        'type': type.name,
      };

  factory MapLocation.fromJson(Map<String, dynamic> json) => MapLocation(
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
        id: json['id'] as String?,
        name: json['name'] as String?,
        type: MapLocationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MapLocationType.other,
        ),
      );
}

enum MapLocationType {
  userLocation,
  pickupSelection,
  apartment,
  bnb,
  serviceLocation,
  other,
}
