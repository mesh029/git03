import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/map_mode.dart';
import '../models/property_listing.dart';

/// In-memory listings provider (dummy DB).
/// Later swap with API + persistence.
class ListingsProvider extends ChangeNotifier {
  final List<PropertyListing> _listings = [];

  List<PropertyListing> get allListings => List.unmodifiable(_listings);
  List<PropertyListing> get availableListings =>
      _listings.where((l) => l.isAvailable).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<PropertyListing> availableByType(PropertyType type) {
    if (type == PropertyType.all) return availableListings;
    return availableListings.where((l) => l.type == type).toList();
  }

  ListingsProvider() {
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    const imagesA = [
      'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
      'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
    ];
    const imagesB = [
      'https://www.figma.com/api/mcp/asset/872fc196-1cb2-42e8-84b0-aa58f49abd5e',
      'https://www.figma.com/api/mcp/asset/36b3c108-6c7b-47dd-8836-3cfe30bafb86',
    ];

    _listings.addAll([
      PropertyListing(
        id: 'listing_apt_milimani_3br',
        agentId: 'user_agent',
        type: PropertyType.apartment,
        title: '3BR Apartment',
        areaLabel: 'Milimani, Kisumu',
        location: const LatLng(-0.0917, 34.7680),
        isAvailable: true,
        priceLabel: 'KSh 15,000/month',
        rating: 4.8,
        traction: 92,
        amenities: const ['Wi‑Fi', 'Parking', 'Water 24/7', 'Security'],
        houseRules: 'No loud parties after 10pm. No smoking indoors.',
        images: imagesA,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      PropertyListing(
        id: 'listing_bnb_milimani_cozy',
        agentId: 'user_agent',
        type: PropertyType.bnb,
        title: 'Cozy BnB',
        areaLabel: 'Milimani, Kisumu',
        location: const LatLng(-0.0930, 34.7690),
        isAvailable: true,
        priceLabel: 'KSh 2,500/night',
        rating: 4.9,
        traction: 140,
        amenities: const ['Wi‑Fi', 'Breakfast', 'Hot shower'],
        houseRules: 'Check-in 2pm. No smoking.',
        images: imagesB,
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      PropertyListing(
        id: 'listing_apt_town_2br',
        agentId: 'user_agent',
        type: PropertyType.apartment,
        title: '2BR Apartment',
        areaLabel: 'Town Center, Kisumu',
        location: const LatLng(-0.0910, 34.7675),
        isAvailable: false, // demonstrate realtime availability
        priceLabel: 'KSh 12,000/month',
        rating: 4.6,
        traction: 65,
        amenities: const ['Parking', 'Security'],
        houseRules: 'No pets.',
        images: imagesA,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      PropertyListing(
        id: 'listing_bnb_sunset',
        agentId: 'user_agent',
        type: PropertyType.bnb,
        title: 'Sunset BnB',
        areaLabel: 'Kisumu',
        location: const LatLng(-0.0870, 34.7710),
        isAvailable: true,
        priceLabel: 'KSh 3,200/night',
        rating: 4.5,
        traction: 44,
        amenities: const ['Wi‑Fi', 'Lake view'],
        houseRules: 'No smoking. Quiet hours 10pm–7am.',
        images: imagesB,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
    ]);
  }

  List<PropertyListing> listingsForAgent(String agentId) {
    return _listings.where((l) => l.agentId == agentId).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  void addListing(PropertyListing listing) {
    _listings.add(listing);
    notifyListeners();
  }

  void updateListing(PropertyListing updated) {
    final idx = _listings.indexWhere((l) => l.id == updated.id);
    if (idx == -1) return;
    _listings[idx] = updated.copyWith(updatedAt: DateTime.now());
    notifyListeners();
  }

  void toggleAvailability(String listingId, bool isAvailable) {
    final idx = _listings.indexWhere((l) => l.id == listingId);
    if (idx == -1) return;
    _listings[idx] = _listings[idx].copyWith(
      isAvailable: isAvailable,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void removeListing(String listingId) {
    _listings.removeWhere((l) => l.id == listingId);
    notifyListeners();
  }
}

