import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../config/map_config.dart';
import '../../models/map_location.dart';
import '../../providers/map_provider.dart';
import '../../services/map/location_service.dart';

/// Provider-agnostic map widget
/// Can be swapped to different map providers by changing MapConfig
class MapWidget extends StatefulWidget {
  final Function(LatLng)? onTap;
  final bool showUserLocation;
  final bool showPlaceholderMarkers;
  final bool showPickupSelection;

  const MapWidget({
    super.key,
    this.onTap,
    this.showUserLocation = true,
    this.showPlaceholderMarkers = true,
    this.showPickupSelection = true,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late final MapController _mapController;
  LatLng? _lastCenteredLocation;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnUserLocation(LatLng? userLocation) {
    if (userLocation != null && 
        (_lastCenteredLocation == null || 
         _lastCenteredLocation != userLocation)) {
      // Center map on user location when it becomes available
      _mapController.move(userLocation, MapConfig.initialZoom);
      _lastCenteredLocation = userLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, _) {
        // Always show the map - use user location if available, otherwise use default
        // This ensures map is always visible and dynamic
        final centerLocation = mapProvider.userLocation ?? 
            const LatLng(-1.2921, 36.8219); // Default: Nairobi, Kenya (central location)
        
        // Center on location when it becomes available or changes
        if (!_hasInitialized || 
            (mapProvider.userLocation != null && 
             _lastCenteredLocation != mapProvider.userLocation)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.move(centerLocation, MapConfig.initialZoom);
              if (mapProvider.userLocation != null) {
                _lastCenteredLocation = mapProvider.userLocation;
              }
              _hasInitialized = true;
            }
          });
        }

        return Stack(
          children: [
            // Map - always visible
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: centerLocation, // Use actual location or default
                initialZoom: MapConfig.initialZoom,
                minZoom: MapConfig.minZoom,
                maxZoom: MapConfig.maxZoom,
                onTap: (tapPosition, point) {
                  if (widget.onTap != null) {
                    widget.onTap!(point);
                  }
                  if (widget.showPickupSelection) {
                    mapProvider.setSelectedPickupLocation(point);
                  }
                },
              ),
              children: [
                // Tile layer - OpenStreetMap
                TileLayer(
                  urlTemplate: MapConfig.tileProviderUrl,
                  userAgentPackageName: 'com.example.juax',
                  maxZoom: MapConfig.maxZoom,
                ),
                // Markers layer - always show markers
                MarkerLayer(
                  markers: _buildMarkers(context, mapProvider),
                ),
              ],
            ),
            // Loading overlay - show while getting location
            if (mapProvider.isLoadingLocation)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Getting your location...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Location status banner - show if there's an error or info message
            if (mapProvider.locationError != null && 
                !mapProvider.isLoadingLocation &&
                mapProvider.locationError!.isNotEmpty)
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mapProvider.locationError!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: () async {
                          await mapProvider.updateUserLocation();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Marker> _buildMarkers(BuildContext context, MapProvider mapProvider) {
    final markers = <Marker>[];

    // Placeholder location markers - show these first so they're always visible
    if (widget.showPlaceholderMarkers && mapProvider.placeholderLocations.isNotEmpty) {
      for (final location in mapProvider.placeholderLocations) {
        markers.add(_buildPlaceholderMarker(context, location));
      }
    }

    // User location marker
    if (widget.showUserLocation && mapProvider.hasUserLocation) {
      markers.add(_buildUserLocationMarker(context, mapProvider.userLocation!));
    }

    // Selected pickup location marker
    if (widget.showPickupSelection && mapProvider.selectedPickupLocation != null) {
      markers.add(_buildPickupMarker(
        context,
        mapProvider.selectedPickupLocation!.toLatLng(),
      ));
    }

    return markers;
  }

  Marker _buildUserLocationMarker(BuildContext context, LatLng position) {
    return Marker(
      point: position,
      width: MapConfig.markerSize,
      height: MapConfig.markerSize,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).cardColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.my_location,
          color: Theme.of(context).cardColor,
          size: 20,
        ),
      ),
    );
  }

  Marker _buildPickupMarker(BuildContext context, LatLng position) {
    return Marker(
      point: position,
      width: MapConfig.selectedMarkerSize,
      height: MapConfig.selectedMarkerSize,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).cardColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          Icons.location_on,
          color: Theme.of(context).cardColor,
          size: 24,
        ),
      ),
    );
  }

  Marker _buildPlaceholderMarker(BuildContext context, MapLocation location) {
    IconData icon;
    Color color;

    switch (location.type) {
      case MapLocationType.apartment:
        icon = Icons.apartment;
        color = Colors.blue;
        break;
      case MapLocationType.bnb:
        icon = Icons.hotel;
        color = Colors.purple;
        break;
      case MapLocationType.serviceLocation:
        icon = Icons.local_laundry_service;
        color = Colors.green;
        break;
      default:
        icon = Icons.place;
        color = Colors.grey;
    }

    return Marker(
      point: location.toLatLng(),
      width: MapConfig.markerSize,
      height: MapConfig.markerSize,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).cardColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Theme.of(context).cardColor,
          size: 20,
        ),
      ),
    );
  }
}
