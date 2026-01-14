import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/map_config.dart';

/// Lightweight map preview widget for cards
/// Centers on a specific location and shows a simple map preview
class MapPreviewWidget extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final Function()? onTap;

  const MapPreviewWidget({
    super.key,
    required this.center,
    this.zoom = 14.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
          minZoom: 3.0,
          maxZoom: 18.0,
          // Disable pan/zoom interactions in preview - just show static map
          // In flutter_map 7.0.2, we can't easily disable interactions, so we'll just not handle them
        ),
        children: [
          // Tile layer - OpenStreetMap
          TileLayer(
            urlTemplate: MapConfig.tileProviderUrl,
            userAgentPackageName: 'com.example.juax',
            maxZoom: MapConfig.maxZoom,
          ),
        ],
      ),
    );
  }
}
