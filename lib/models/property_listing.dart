import 'package:latlong2/latlong.dart';
import 'map_mode.dart';

/// Agent-managed listing that powers Apartments/BnBs shown to users.
class PropertyListing {
  final String id;
  final String agentId;
  final PropertyType type;
  final String title;
  final String areaLabel; // human label e.g. "Milimani, Kisumu"
  final LatLng location;

  final bool isAvailable;
  final String priceLabel; // e.g. "KSh 2,500/night" or "KSh 15,000/month"
  final double rating; // 1..5
  final int traction; // simple popularity metric
  final List<String> amenities;
  final String houseRules;
  final List<String> images;

  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyListing({
    required this.id,
    required this.agentId,
    required this.type,
    required this.title,
    required this.areaLabel,
    required this.location,
    required this.isAvailable,
    required this.priceLabel,
    required this.rating,
    required this.traction,
    required this.amenities,
    required this.houseRules,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  PropertyListing copyWith({
    String? id,
    String? agentId,
    PropertyType? type,
    String? title,
    String? areaLabel,
    LatLng? location,
    bool? isAvailable,
    String? priceLabel,
    double? rating,
    int? traction,
    List<String>? amenities,
    String? houseRules,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyListing(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      type: type ?? this.type,
      title: title ?? this.title,
      areaLabel: areaLabel ?? this.areaLabel,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      priceLabel: priceLabel ?? this.priceLabel,
      rating: rating ?? this.rating,
      traction: traction ?? this.traction,
      amenities: amenities ?? this.amenities,
      houseRules: houseRules ?? this.houseRules,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'type': type.name,
      'title': title,
      'areaLabel': areaLabel,
      'lat': location.latitude,
      'lng': location.longitude,
      'isAvailable': isAvailable,
      'priceLabel': priceLabel,
      'rating': rating,
      'traction': traction,
      'amenities': amenities,
      'houseRules': houseRules,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PropertyListing.fromJson(Map<String, dynamic> json) {
    return PropertyListing(
      id: json['id'] as String,
      agentId: json['agentId'] as String,
      type: PropertyType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PropertyType.apartment,
      ),
      title: json['title'] as String,
      areaLabel: json['areaLabel'] as String,
      location: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      isAvailable: json['isAvailable'] as bool? ?? true,
      priceLabel: json['priceLabel'] as String,
      rating: (json['rating'] as num).toDouble(),
      traction: (json['traction'] as num?)?.toInt() ?? 0,
      amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      houseRules: json['houseRules'] as String? ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

}

