import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/map_mode.dart';
import '../widgets/map/property_map_bottom_sheet.dart';
import '../widgets/map/laundry_map_bottom_sheet.dart';
import '../widgets/map/cleaning_map_bottom_sheet.dart';
import '../widgets/map/ride_map_bottom_sheet.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home_screen.dart';

class MapScreen extends StatelessWidget {
  final MapMode mode;
  final Map<String, dynamic>? data;

  const MapScreen({
    super.key,
    required this.mode,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Map background
          _buildMapBackground(context),
          // Location pins on map (dynamic based on mode)
          ..._buildLocationPins(),
          // Top navigation bar
          _buildTopNavigation(context),
          // Bottom section (dynamic based on mode)
          _buildBottomSection(context),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 1, // Services tab active on map
        onTap: (index) {
          if (index == 0) {
            // Navigate to home
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          } else {
            // Handle other tabs (Services, Orders, Messages, Profile)
            // TODO: Navigate to respective screens
          }
        },
      ),
    );
  }

  Widget _buildMapBackground(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Image.network(
        'https://www.figma.com/api/mcp/asset/26b19d5c-d5e0-479a-899f-e50a8e0022d2',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Map View',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildLocationPins() {
    // Location pins positioned on the map (dynamic based on mode)
    final pinPositions = _getPinPositionsForMode();
    
    return pinPositions.map((position) {
      return _buildLocationPin(
        left: position.dx,
        top: position.dy,
      );
    }).toList();
  }

  List<Offset> _getPinPositionsForMode() {
    switch (mode) {
      case MapMode.properties:
        // Property locations
        return [
          const Offset(181, 300),
          const Offset(148, 213),
          const Offset(121, 367),
          const Offset(318, 450),
          const Offset(53, 211),
          const Offset(337, 329),
          const Offset(243, 316),
          const Offset(195, 448),
        ];
      case MapMode.laundry:
        // Laundry pickup stations
        return [
          const Offset(150, 250),
          const Offset(200, 300),
          const Offset(280, 350),
          const Offset(100, 400),
        ];
      case MapMode.cleaning:
        // Cleaning service locations
        return [
          const Offset(120, 220),
          const Offset(250, 300),
          const Offset(180, 380),
        ];
      case MapMode.rides:
        // Ride pickup points
        return [
          const Offset(120, 200),
          const Offset(250, 280),
          const Offset(180, 380),
        ];
    }
  }

  Widget _buildLocationPin({required double left, required double top}) {
    Color pinColor;
    switch (mode) {
      case MapMode.properties:
        pinColor = const Color(0xFF0373F3); // Blue for properties
        break;
      case MapMode.laundry:
        pinColor = const Color(0xFF8B5CF6); // Purple for laundry
        break;
      case MapMode.cleaning:
        pinColor = const Color(0xFF8B5CF6); // Purple for cleaning (same brand)
        break;
      case MapMode.rides:
        pinColor = const Color(0xFF10B981); // Green for rides
        break;
    }

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pinColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.location_on,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildTopNavigation(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            // Back button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).iconTheme.color ?? Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 16),
            // Search bar
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 15),
                    const Icon(
                      Icons.search,
                      size: 22,
                      color: Color(0xFFAEAEAE),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        _getSearchPlaceholder(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFAEAEAE),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Filter button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getFilterButtonColor(),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSearchPlaceholder() {
    switch (mode) {
      case MapMode.properties:
        return 'Search properties...';
      case MapMode.laundry:
        return 'Search pickup stations...';
      case MapMode.cleaning:
        return 'Search service location...';
      case MapMode.rides:
        return 'Search location...';
    }
  }

  Color _getFilterButtonColor() {
    switch (mode) {
      case MapMode.properties:
        return const Color(0xFF0373F3);
      case MapMode.laundry:
        return const Color(0xFF8B5CF6);
      case MapMode.cleaning:
        return const Color(0xFF8B5CF6);
      case MapMode.rides:
        return const Color(0xFF10B981);
    }
  }

  Widget _buildBottomSection(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Theme.of(context).cardColor.withValues(alpha: 0.95),
              Theme.of(context).cardColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Title
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Text(
                  mode.title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).iconTheme.color ?? Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Dynamic bottom sheet based on mode
              _buildModeSpecificBottomSheet(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSpecificBottomSheet(BuildContext context) {
    switch (mode) {
      case MapMode.properties:
        return PropertyMapBottomSheet(data: data);
      case MapMode.laundry:
        return LaundryMapBottomSheet(data: data);
      case MapMode.cleaning:
        return CleaningMapBottomSheet(data: data);
      case MapMode.rides:
        return RideMapBottomSheet(data: data);
    }
  }
}
