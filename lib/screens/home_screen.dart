import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'map_screen.dart';
import 'property_detail_screen.dart';
import 'fresh_keja_service_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'admin_orders_screen.dart';
import 'agent_dashboard_screen.dart';
import 'messages_screen.dart';
import '../models/map_mode.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/map_provider.dart';
import '../providers/listings_provider.dart';
import '../services/map/location_name_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Database-ready featured listings - replace with API call later
  static List<Map<String, dynamic>> getFeaturedListings() {
    return [
      {
        'id': '3br_apartment_milimani',
        'title': '3BR Apartment',
        'location': 'Milimani, Kisumu',
        'price': 'KSh 15,000/month',
        'rating': '4.8',
        'type': PropertyType.apartment,
        'images': [
          'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
          'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
          'https://www.figma.com/api/mcp/asset/872fc196-1cb2-42e8-84b0-aa58f49abd5e',
          'https://www.figma.com/api/mcp/asset/36b3c108-6c7b-47dd-8836-3cfe30bafb86',
        ],
      },
      {
        'id': '2br_apartment_town_center',
        'title': '2BR Apartment',
        'location': 'Town Center, Kisumu',
        'price': 'KSh 12,000/month',
        'rating': '4.6',
        'type': PropertyType.apartment,
        'images': [
          'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
          'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
        ],
      },
      {
        'id': 'bnb_milimani',
        'title': 'Cozy BNB',
        'location': 'Milimani, Kisumu',
        'price': 'KSh 2,500/night',
        'rating': '4.9',
        'type': PropertyType.bnb,
        'images': [
          'https://www.figma.com/api/mcp/asset/872fc196-1cb2-42e8-84b0-aa58f49abd5e',
          'https://www.figma.com/api/mcp/asset/36b3c108-6c7b-47dd-8836-3cfe30bafb86',
        ],
      },
      {
        'id': '1br_apartment_nyalenda',
        'title': '1BR Apartment',
        'location': 'Nyalenda, Kisumu',
        'price': 'KSh 8,000/month',
        'rating': '4.5',
        'type': PropertyType.apartment,
        'images': [
          'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
        ],
      },
      {
        'id': 'studio_apartment_town',
        'title': 'Studio Apartment',
        'location': 'Town Center, Kisumu',
        'price': 'KSh 6,500/month',
        'rating': '4.4',
        'type': PropertyType.apartment,
        'images': [
          'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
        ],
      },
    ];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  /// Check if user is in Kisumu area (approximately)
  bool _isInKisumuArea(double? latitude, double? longitude) {
    return LocationNameService.isInKisumuArea(latitude, longitude);
  }

  // Location name is now fetched from MapProvider (which uses Mapbox API)
  // No need for local method anymore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Hero section - Clean, theme-based
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Consumer2<AuthProvider, MapProvider>(
                      builder: (context, authProvider, mapProvider, _) {
                        final user = authProvider.currentUser;
                        final userName = user?.name ?? 'Guest';
                        final greeting = _getGreeting();
                        
                        // Get location name from MapProvider (fetched from Mapbox API)
                        final locationName = mapProvider.isLoadingLocationName
                            ? 'Getting location...'
                            : (mapProvider.locationName ?? 
                               (mapProvider.isLoadingLocation 
                                   ? 'Getting location...' 
                                   : 'Current Location'));
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location - theme-based
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    locationName,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Greeting
                            Text(
                              greeting,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // User name
                            Text(
                              userName,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Dark mode toggle - minimal
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return IconButton(
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: Theme.of(context).iconTheme.color,
                          size: 22,
                        ),
                        onPressed: () {
                          themeProvider.toggleTheme();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Content area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primary hero card - Saka Keja (largest, highest visual weight)
                      _buildAirbnbServiceCard(
                        context,
                        title: 'Saka Keja',
                        subtitle: 'Find apartments and BnBs',
                        icon: Icons.home,
                        isPrimary: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapScreen(
                                mode: MapMode.properties,
                                data: {'service': 'Saka Keja', 'type': 'all'},
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Secondary service card - Laundry (same pattern, less emphasis)
                      _buildAirbnbServiceCard(
                        context,
                        title: 'Laundry (Mama Fua)',
                        subtitle: 'Book laundry and cleaning services',
                        icon: Icons.local_laundry_service,
                        isPrimary: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FreshKejaServiceScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // Other services section
                      Text(
                        'Other services',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildOtherServiceRow(
                        context,
                        icon: Icons.directions_car,
                        label: 'RideX',
                        subtitle: 'Coming soon',
                      ),
                      const SizedBox(height: 32),
                      // Featured Listings section
                      Text(
                        'Featured Listings',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<ListingsProvider>(
                        builder: (context, listingsProvider, _) {
                          final listings = listingsProvider.availableListings;
                          if (listings.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final first = listings.first;
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PropertyDetailScreen(
                                        propertyId: first.id,
                                        title: first.title,
                                        location: first.areaLabel,
                                        price: first.priceLabel,
                                        rating: first.rating.toStringAsFixed(1),
                                        type: first.type,
                                        images: first.images,
                                        details: {
                                          'amenities': first.amenities,
                                          'houseRules': first.houseRules,
                                          'traction': first.traction,
                                          'isAvailable': first.isAvailable,
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: _buildFeaturedPropertyCard(
                                  context,
                                  first.title,
                                  first.areaLabel.split(',').first,
                                  first.priceLabel,
                                  first.rating.toStringAsFixed(1),
                                ),
                              ),
                              if (listings.length > 1) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 138,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(
                                      parent: AlwaysScrollableScrollPhysics(),
                                    ),
                                    itemCount: listings.length - 1,
                                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final l = listings[index + 1];
                                      return SizedBox(
                                        width: 230,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PropertyDetailScreen(
                                                  propertyId: l.id,
                                                  title: l.title,
                                                  location: l.areaLabel,
                                                  price: l.priceLabel,
                                                  rating: l.rating.toStringAsFixed(1),
                                                  type: l.type,
                                                  images: l.images,
                                                  details: {
                                                    'amenities': l.amenities,
                                                    'houseRules': l.houseRules,
                                                    'traction': l.traction,
                                                    'isAvailable': l.isAvailable,
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          child: _buildServiceCard(
                                            context,
                                            l.type == PropertyType.bnb ? Icons.hotel : Icons.apartment,
                                            l.title,
                                            Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return AppBottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 0) {
                // Already on home
                return;
              } else if (index == 1) {
                // Services - disabled, should be accessed from home page actions
                // Do nothing - services can only be accessed via home page quick actions
                return;
              } else if (index == 2) {
                // Orders
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                  (route) => route.settings.name == '/home' || route.isFirst,
                );
              } else if (index == 3) {
                // Profile
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  (route) => route.settings.name == '/home' || route.isFirst,
                );
              } else if (index == 4) {
                if (authProvider.isAdmin) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
                    (route) => route.settings.name == '/home' || route.isFirst,
                  );
                } else if (authProvider.isAgent) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AgentDashboardScreen()),
                    (route) => route.settings.name == '/home' || route.isFirst,
                  );
                }
              } else if (index == 5) {
                // Messages
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                  (route) => route.settings.name == '/home' || route.isFirst,
                );
              }
            },
          );
        },
      ),
    );
  }

  // Airbnb-style service card - Large, clean, full-width cards with Material 3 colors
  Widget _buildAirbnbServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
    bool isDisabled = false,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    
    // UI Design Principle: Cards use consistent surface color, only icons/buttons use accent colors
    final accentColor = isPrimary ? primaryColor : secondaryColor;
    
    // Refactoring UI: Use spacing for hierarchy before color
    final cardPadding = isPrimary ? 24.0 : 20.0;
    final iconSize = isPrimary ? 72.0 : 64.0;
    final iconInnerSize = isPrimary ? 36.0 : 32.0;
    final titleSize = isPrimary ? 20.0 : 18.0;
    final shadowElevation = isPrimary ? 12.0 : 8.0;
    
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          // Consistent card color - all cards use surface/cardColor
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isDisabled 
              ? Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.06),
              blurRadius: shadowElevation,
              offset: Offset(0, isPrimary ? 4 : 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon - Left side, using accent color with subtle background
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: isDisabled
                    ? mutedColor?.withOpacity(0.1)
                    : accentColor.withOpacity(0.1), // Subtle accent tint
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDisabled ? mutedColor : accentColor, // Accent color for icon
                size: iconInnerSize,
              ),
            ),
            const SizedBox(width: 20),
            // Content - Middle, flexible
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: titleSize,
                      fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                      // Consistent text color on cards
                      color: isDisabled 
                          ? mutedColor 
                          : Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      // Consistent text color for subtitle
                      color: isDisabled 
                          ? mutedColor 
                          : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow or badge - Right side
            if (isDisabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mutedColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Soon',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: mutedColor,
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
          ],
        ),
      ),
    );
  }

  // Primary service card - Following UI design principles
  // Cards use consistent surface colors, only buttons/icons use accent colors
  Widget _buildPrimaryServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardPadding = isPrimary ? 24.0 : 20.0;
    final iconSize = isPrimary ? 56.0 : 48.0;
    final iconInnerSize = isPrimary ? 28.0 : 24.0;
    
    // UI Design Principle: Cards use surface color, only CTAs use primary/secondary
    // Icon background uses subtle primary/secondary tint, not full container color
    final iconBgColor = isPrimary 
        ? colorScheme.primary.withOpacity(0.1)
        : colorScheme.secondary.withOpacity(0.1);
    final iconColor = isPrimary 
        ? colorScheme.primary 
        : colorScheme.secondary;
    final buttonColor = isPrimary 
        ? colorScheme.primary 
        : colorScheme.secondary;
    final onButtonColor = isPrimary 
        ? colorScheme.onPrimary 
        : colorScheme.onSecondary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Consistent card color
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isPrimary ? 12 : 8,
              offset: Offset(0, isPrimary ? 4 : 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon with subtle accent color background
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: iconBgColor, // Subtle tint, not full container
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor, // Primary/secondary for icon
                    size: iconInnerSize,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ],
            ),
            SizedBox(height: isPrimary ? 24 : 20),
            // Larger title (24px)
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle with better spacing
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            SizedBox(height: isPrimary ? 20 : 16),
            // Button using primary/secondary colors (CTA)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: onButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isPrimary ? 'Start moving' : 'Book laundry',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Other service row - Enhanced with refined borders and pill badge
  Widget _buildOtherServiceRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Smaller, more refined icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: mutedColor?.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: mutedColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Pill-shaped "Coming soon" badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: mutedColor?.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20), // Pill shape
            ),
            child: Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: mutedColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Service Row - for popular services (minimal, flat)
  Widget _buildServiceRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String rating,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 14,
                  color: Theme.of(context).colorScheme.secondary, // Orange for ratings
                ),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  // Service cards - using exact Figma dimensions: 230x138
  Widget _buildServiceCard(BuildContext context, IconData icon, String label, Color color, {bool isActive = true}) {
    return Container(
      width: 230,
      height: 138,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (isActive ? color : Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF)).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? color : Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive 
                        ? Theme.of(context).textTheme.titleLarge?.color
                        : Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                  ),
                ),
                if (!isActive) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Soon',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Popular service cards - using exact Figma dimensions: 230x138, fixed overflow
  Widget _buildPopularServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    String rating,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 230,
      height: 138,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Service Area cards with image backgrounds - using exact Figma dimensions: 142x200
  Widget _buildServiceAreaCard(
    BuildContext context,
    String neighborhood,
    int propertyCount,
    int serviceProviderCount,
    String imageUrl,
  ) {
    return Container(
      width: 142,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).dividerColor,
                  child: Icon(
                    Icons.image,
                    color: Theme.of(context).cardColor,
                    size: 48,
                  ),
                );
              },
            ),
            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.7) ?? Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content overlay
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top spacing
                  const SizedBox(),
                  // Bottom content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        neighborhood,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            size: 12,
                            color: Theme.of(context).cardColor.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$propertyCount properties',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).cardColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_laundry_service,
                            size: 12,
                            color: Theme.of(context).cardColor.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$serviceProviderCount providers',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).cardColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Featured Property card - Using Material 3 colors
  Widget _buildFeaturedPropertyCard(
    BuildContext context,
    String title,
    String location,
    String price,
    String rating,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = colorScheme.primary;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Consistent card color - all cards use surface/cardColor
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              // Use primary color with opacity for icon background
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.home,
              color: primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price using Material 3 primary color
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.secondary, // Orange star
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).textTheme.bodySmall?.color,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Featured Service card - smaller card for service providers
  Widget _buildFeaturedServiceCard(
    BuildContext context,
    String providerName,
    String availability,
    String rating,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    rating,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            providerName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            availability,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
            size: 24,
          ),
        ],
      ),
    );
  }

}
