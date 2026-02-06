import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../config/map_config.dart';
import '../models/map_location.dart';
import '../services/map/location_service.dart';
import '../services/map/location_name_service.dart';

/// Provider for map state and location management
class MapProvider extends ChangeNotifier {
  LatLng? _userLocation;
  MapLocation? _selectedPickupLocation;
  List<MapLocation> _placeholderLocations = [];
  bool _isLoadingLocation = false;
  String? _locationError;
  String? _locationName;
  bool _isLoadingLocationName = false;

  LatLng? get userLocation => _userLocation;
  MapLocation? get selectedPickupLocation => _selectedPickupLocation;
  List<MapLocation> get placeholderLocations => _placeholderLocations;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;
  String? get locationName => _locationName;
  bool get isLoadingLocationName => _isLoadingLocationName;
  bool get hasUserLocation => _userLocation != null;

  MapProvider() {
    // Initialize placeholder locations immediately (synchronous)
    // This ensures markers are always available
    _initializePlaceholderLocations();
    // Initialize user location asynchronously - this will request permission
    // and get the actual GPS location
    _initializeUserLocation();
    // Don't notify here - wait for actual location to be obtained
  }

  /// Initialize placeholder markers (apartments, BnBs, services)
  void _initializePlaceholderLocations() {
    // Sample service locations (laundry/cleaning stations).
    // Apartments/BnBs are now agent-managed via ListingsProvider and should not be hardcoded here.
    _placeholderLocations = [
      // Service locations
      MapLocation(
        latitude: -0.0920,
        longitude: 34.7685,
        id: 'service_1',
        name: 'Laundry Station',
        type: MapLocationType.serviceLocation,
      ),
      MapLocation(
        latitude: -0.0890,
        longitude: 34.7660,
        id: 'service_2',
        name: 'Cleaning Service',
        type: MapLocationType.serviceLocation,
      ),
      MapLocation(
        latitude: -0.0940,
        longitude: 34.7695,
        id: 'service_3',
        name: 'Express Laundry',
        type: MapLocationType.serviceLocation,
      ),
    ];
    // Don't notify listeners here - will notify when user location is loaded
  }

  /// Initialize and get user's current location
  Future<void> _initializeUserLocation() async {
    await updateUserLocation();
  }

  /// Update user's current location
  Future<void> updateUserLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      final position = await LocationService.getCurrentLocation();
      
      if (position != null) {
        // Success! Use actual GPS location
        _userLocation = LatLng(position.latitude, position.longitude);
        _locationError = null; // Clear any previous errors - GPS is working!
        
        // Fetch location name from Mapbox API
        _updateLocationName(position.latitude, position.longitude);
      } else {
        // Couldn't get location - use a reasonable default that allows map to show
        // Use a central location (Nairobi, Kenya) as fallback so map is always visible
        // This allows users to browse even without GPS
        _userLocation = const LatLng(-1.2921, 36.8219); // Nairobi, Kenya (central location)
        
        // Fetch location name for default location too
        _updateLocationName(-1.2921, 36.8219);
        
        // Check why we couldn't get location
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        final hasPermission = await LocationService.hasPermission();
        
        // Set appropriate error message (but don't block map)
        if (!serviceEnabled) {
          _locationError = 'GPS disabled. Showing default location. Enable GPS for accurate location.';
        } else if (!hasPermission) {
          _locationError = 'Location permission needed. Showing default location. Grant permission for accurate location.';
        } else {
          // GPS enabled, permission granted, but couldn't get location
          _locationError = 'Using default location. Tap to retry getting your location.';
        }
      }
    } catch (e) {
      // Error getting location - use fallback so map still shows
      _userLocation = const LatLng(-1.2921, 36.8219); // Nairobi, Kenya as fallback
      _locationError = 'Using default location. Tap to retry.';
      _updateLocationName(-1.2921, 36.8219);
    }

    _isLoadingLocation = false;
    // Always notify to ensure markers are visible
    notifyListeners();
  }

  /// Update location name from Mapbox API
  Future<void> _updateLocationName(double latitude, double longitude) async {
    _isLoadingLocationName = true;
    notifyListeners();

    try {
      // Use Mapbox API via backend to get location name
      final name = await LocationNameService.getLocationName(latitude, longitude);
      _locationName = name;
    } catch (e) {
      // Fallback to sync method if API fails
      _locationName = LocationNameService.getLocationNameSync(latitude, longitude);
    } finally {
      _isLoadingLocationName = false;
      notifyListeners();
    }
  }

  /// Refresh location name (useful when location changes)
  Future<void> refreshLocationName() async {
    if (_userLocation != null) {
      await _updateLocationName(_userLocation!.latitude, _userLocation!.longitude);
    }
  }

  /// Set selected pickup location from map tap
  void setSelectedPickupLocation(LatLng location, {String? name}) {
    _selectedPickupLocation = MapLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      name: name ?? 'Selected Location',
      type: MapLocationType.pickupSelection,
    );
    // Fetch location name asynchronously
    _updateSelectedLocationName(location.latitude, location.longitude);
    notifyListeners();
  }

  /// Update selected location name from Mapbox API
  Future<void> _updateSelectedLocationName(double latitude, double longitude) async {
    try {
      final name = await LocationNameService.getLocationName(latitude, longitude);
      if (_selectedPickupLocation != null) {
        _selectedPickupLocation = MapLocation(
          latitude: _selectedPickupLocation!.latitude,
          longitude: _selectedPickupLocation!.longitude,
          name: name,
          type: _selectedPickupLocation!.type,
        );
        notifyListeners();
      }
    } catch (e) {
      // If API fails, keep the default name
      // Fallback is already handled in LocationNameService
    }
  }

  /// Clear selected pickup location
  void clearSelectedPickupLocation() {
    _selectedPickupLocation = null;
    notifyListeners();
  }

  /// Get selected pickup location as LatLng
  LatLng? getSelectedPickupLatLng() {
    return _selectedPickupLocation?.toLatLng();
  }

  /// Get selected pickup location coordinates for use in orders
  Map<String, dynamic>? getSelectedPickupLocationData() {
    if (_selectedPickupLocation == null) return null;
    
    return {
      'latitude': _selectedPickupLocation!.latitude,
      'longitude': _selectedPickupLocation!.longitude,
      'name': _selectedPickupLocation!.name,
      'address': _selectedPickupLocation!.name, // Can be enhanced with reverse geocoding
    };
  }
}
