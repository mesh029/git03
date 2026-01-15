import 'package:flutter/material.dart';
import '../models/map_mode.dart';
import '../widgets/map/property_map_bottom_sheet.dart';
import '../widgets/map/laundry_map_bottom_sheet.dart';
import '../widgets/map/cleaning_map_bottom_sheet.dart';
import '../widgets/map/ride_map_bottom_sheet.dart';
import '../widgets/map/map_widget.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'admin_orders_screen.dart';
import 'agent_dashboard_screen.dart';
import 'messages_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/map_provider.dart';
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
          // Map background - fills entire screen
          Positioned.fill(
            child: _buildMapBackground(context),
          ),
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
              } else if (index == 4) {
                if (authProvider.isAdmin) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
                    (route) => false,
                  );
                } else if (authProvider.isAgent) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AgentDashboardScreen()),
                    (route) => false,
                  );
                }
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
    return Consumer<MapProvider>(
      builder: (context, mapProvider, _) {
        return Stack(
          children: [
            // OpenStreetMap - fills entire background
            MapWidget(
              showUserLocation: true,
              showPlaceholderMarkers: true,
              showPickupSelection: true,
            ),
            // Loading indicator - MapWidget now handles this internally
            // But we keep this as a backup overlay
            if (mapProvider.isLoadingLocation)
              Container(
                color: Colors.black.withOpacity(0.3),
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
            // "You are here" indicator - only show if we have actual GPS location
            // Don't show if there's an error or if we're still loading
            if (mapProvider.hasUserLocation && 
                !mapProvider.isLoadingLocation &&
                mapProvider.locationError == null)
              Positioned(
                top: 100,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Theme.of(context).cardColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'You are here',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).cardColor,
                          fontWeight: FontWeight.w600,
                        ),
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

  List<Widget> _buildLocationPins() {
    // Markers are now handled by MapWidget
    // This method is kept for compatibility but returns empty list
    return [];
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
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 12),
              // Search bar
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 20,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 12),
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

  Widget _buildBottomSection(BuildContext context) {
    // For Fresh Keja services (laundry/cleaning), make bottom sheet smaller to show more map
    final isFreshKejaService = mode == MapMode.laundry || mode == MapMode.cleaning;
    
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
              // Drag handle for Fresh Keja services
              if (isFreshKejaService) ...[
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                const SizedBox(height: 20),
              ],
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  mode.title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 16),
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
