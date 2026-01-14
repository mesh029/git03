# OpenStreetMap Integration - Architecture Documentation

## Folder Structure

```
lib/
├── config/
│   └── map_config.dart              # Centralized map configuration
├── services/
│   └── map/
│       └── location_service.dart    # Location permission & GPS service
├── providers/
│   └── map_provider.dart            # Map state management
├── models/
│   └── map_location.dart            # Location data model
└── widgets/
    └── map/
        └── map_widget.dart          # Provider-agnostic map widget
```

## Architecture Overview

### 1. Configuration Layer (`config/map_config.dart`)
- **Purpose**: Single source of truth for map settings
- **Swappable**: Change tile provider URL to switch from OpenStreetMap to Mapbox/others
- **No API keys required**: Uses free OpenStreetMap tiles

### 2. Service Layer (`services/map/location_service.dart`)
- **Location Permissions**: Handles Android/iOS/Web permission requests
- **GPS Access**: Wraps geolocator for current location
- **Location Streams**: Provides real-time location updates
- **Distance Calculations**: Utility for calculating distances

### 3. Provider Layer (`providers/map_provider.dart`)
- **State Management**: Manages user location, selected pickup, placeholder markers
- **Location Updates**: Auto-fetches user location on init
- **Pickup Selection**: Stores selected pickup location from map taps
- **Placeholder Data**: Hardcoded sample locations (apartments, BnBs, services)

### 4. UI Layer (`widgets/map/map_widget.dart`)
- **Provider-Agnostic**: UI doesn't know about OpenStreetMap vs Mapbox
- **Markers**: Renders user location, pickup selection, placeholder locations
- **Interactions**: Handles map taps for pickup selection
- **Theming**: Supports dark/light mode

## Key Features

### ✅ Implemented
- [x] OpenStreetMap integration (free, no API keys)
- [x] GPS location permission handling
- [x] Auto-center on user location
- [x] "You are here" marker and indicator
- [x] Tap to select pickup location
- [x] Placeholder markers (apartments, BnBs, services)
- [x] Different marker icons/colors for each type
- [x] Location exposed to UI layer via MapProvider
- [x] Flutter Web compatible
- [x] Dark/light mode support

### 📍 Marker Types
- **User Location**: Green circle with `my_location` icon
- **Pickup Selection**: Orange circle with `location_on` icon
- **Apartments**: Blue circle with `apartment` icon
- **BnBs**: Purple circle with `hotel` icon
- **Service Locations**: Green circle with `local_laundry_service` icon

## Usage

### Accessing User Location
```dart
final mapProvider = Provider.of<MapProvider>(context);
final userLocation = mapProvider.userLocation; // LatLng?
```

### Getting Selected Pickup Location
```dart
final pickupData = mapProvider.getSelectedPickupLocationData();
// Returns: {latitude, longitude, name, address}
```

### Using Map Widget
```dart
MapWidget(
  showUserLocation: true,
  showPlaceholderMarkers: true,
  showPickupSelection: true,
  onTap: (location) {
    // Handle custom tap logic
  },
)
```

## Switching Map Providers

To switch from OpenStreetMap to Mapbox (or another provider):

1. Update `lib/config/map_config.dart`:
```dart
static const String tileProviderUrl = 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={token}';
```

2. No other code changes needed - MapWidget is provider-agnostic!

## Permissions

### Android
Already configured in `android/app/src/main/AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby services</string>
```

### Web
Uses browser's geolocation API (handled by geolocator).

## Dependencies Added

```yaml
flutter_map: ^7.0.2      # OpenStreetMap rendering
geolocator: ^12.0.0      # GPS location access
latlong2: ^0.9.1         # Lat/Lng coordinate handling
permission_handler: ^11.3.1  # Permission management
```

## Integration Points

The map is integrated into:
- `lib/screens/map_screen.dart` - Main map screen
- Bottom sheets can access pickup location via `MapProvider`
- Future routing logic can use `mapProvider.userLocation` and `mapProvider.selectedPickupLocation`

## Testing

1. **Location Permission**: App will request on first map view
2. **GPS**: Enable location services for accurate positioning
3. **Fallback**: Uses Kisumu, Kenya coordinates if GPS unavailable
4. **Map Taps**: Tap anywhere on map to select pickup location
5. **Markers**: All placeholder markers visible immediately
