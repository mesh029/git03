import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/map_mode.dart';
import '../widgets/map/property_map_bottom_sheet.dart';
import '../widgets/map/laundry_map_bottom_sheet.dart';
import '../widgets/map/cleaning_map_bottom_sheet.dart';
import '../widgets/map/ride_map_bottom_sheet.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'admin_orders_screen.dart';
import 'messages_screen.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

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
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return AppBottomNavigationBar(
            currentIndex: 1, // Services tab active on map
            onTap: (index) {
              if (index == 0) {
                // Navigate to home
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 1) {
                // Already on services/map
                return;
              } else if (index == 2) {
                // Orders
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                  (route) => false,
                );
              } else if (index == 3) {
                // Profile
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  (route) => false,
                );
              } else if (index == 4 && authProvider.isAdmin) {
                // Admin
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
                  (route) => false,
                );
              } else if (index == 5) {
                // Messages
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                  (route) => false,
                );
              }
            },
          );
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
                    style: Theme.of(context).textTheme.bodyMedium,
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
    // Use Spotify green as primary color for pins
    const pinColor = Color(0xFF1DB954); // Spotify green - vibrant and cool
    
    return pinPositions.map((position) {
      return _buildLocationPin(
        left: position.dx,
        top: position.dy,
        color: pinColor,
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

  Widget _buildLocationPin({required double left, required double top, required Color color}) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: const Icon(
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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            // Back button - minimal
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 12),
            // Search bar - minimal
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.search,
                      size: 20,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _getSearchPlaceholder(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Filter button - minimal
            IconButton(
              icon: Icon(
                Icons.tune,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
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

  // Removed _getFilterButtonColor - no longer needed

  Widget _buildBottomSection(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  mode.title,
                  style: Theme.of(context).textTheme.displaySmall,
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
