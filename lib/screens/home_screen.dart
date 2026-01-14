import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'map_screen.dart';
import 'property_detail_screen.dart';
import 'fresh_keja_service_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import '../models/map_mode.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

// Spotify-inspired color constants
class AppColors {
  // Spotify green - vibrant primary color
  static const primary = Color(0xFF1DB954); // Spotify green
  static const primaryDark = Color(0xFF1DB954); // Same green in dark mode
  
  // Accent (for ratings, highlights)
  static const accent = Color(0xFFFFD700); // Gold for ratings (like Spotify uses for premium)
  
  // Light mode (Spotify uses white/very light)
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF000000);
  static const lightTextSecondary = Color(0xFF6A6A6A);
  
  // Dark mode (Spotify uses pure black)
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF121212);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFB3B3B3);
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top section - flat, no gradient
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with greeting and profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            final user = authProvider.currentUser;
                            final userName = user?.name ?? 'Guest';
                            final greeting = _getGreeting();
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greeting,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userName,
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Kisumu – Milimani',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Dark mode toggle and profile - minimal, no shadows
                      Row(
                        children: [
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  const SearchBarWidget(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Access section - icon + label rows (Spotify style)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Access',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          _buildQuickAccessRow(
                            context,
                            icon: Icons.local_laundry_service,
                            label: 'Fresh Keja',
                            subtitle: 'Laundry & cleaning',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FreshKejaServiceScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildQuickAccessRow(
                            context,
                            icon: Icons.home,
                            label: 'Saka Keja',
                            subtitle: 'Find properties',
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
                          const SizedBox(height: 12),
                          _buildQuickAccessRow(
                            context,
                            icon: Icons.directions_car,
                            label: 'RideX',
                            subtitle: 'Coming soon',
                            onTap: null,
                            isDisabled: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Popular Services section - simplified list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Popular Services',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          _buildServiceRow(
                            context,
                            icon: Icons.local_laundry_service,
                            title: 'Fresh Keja',
                            subtitle: 'Laundry & house cleaning',
                            rating: '4.8',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapScreen(
                                    mode: MapMode.laundry,
                                    data: {'service': 'Fresh Keja'},
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildServiceRow(
                            context,
                            icon: Icons.home,
                            title: 'Saka Keja',
                            subtitle: 'BNBs & apartments',
                            rating: '4.9',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Service Areas section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Areas',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // Service areas cards - Kisumu neighborhoods
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MapScreen(
                                      mode: MapMode.properties,
                                      data: {'area': 'Milimani'},
                                    ),
                                  ),
                                );
                              },
                              child: _buildServiceAreaCard(
                                context,
                                'Milimani',
                                12,
                                8,
                                'https://www.figma.com/api/mcp/asset/872fc196-1cb2-42e8-84b0-aa58f49abd5e',
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MapScreen(
                                      mode: MapMode.properties,
                                      data: {'area': 'Town Center'},
                                    ),
                                  ),
                                );
                              },
                              child: _buildServiceAreaCard(
                                context,
                                'Town Center',
                                24,
                                15,
                                'https://www.figma.com/api/mcp/asset/36b3c108-6c7b-47dd-8836-3cfe30bafb86',
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MapScreen(
                                      mode: MapMode.properties,
                                      data: {'area': 'Nyalenda'},
                                    ),
                                  ),
                                );
                              },
                              child: _buildServiceAreaCard(
                                context,
                                'Nyalenda',
                                18,
                                12,
                                'https://www.figma.com/api/mcp/asset/8cc9e310-660f-4428-a71a-c224d2279138',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Featured Listings section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured Listings',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // Featured listings - properties only (database-ready)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // First featured property (large card)
                          Builder(
                            builder: (context) {
                              final listings = getFeaturedListings();
                              if (listings.isEmpty) return const SizedBox.shrink();
                              
                              final firstListing = listings[0];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PropertyDetailScreen(
                                        propertyId: firstListing['id'] as String,
                                        title: firstListing['title'] as String,
                                        location: firstListing['location'] as String,
                                        price: firstListing['price'] as String,
                                        rating: firstListing['rating'] as String,
                                        type: firstListing['type'] as PropertyType,
                                        images: (firstListing['images'] as List).cast<String>(),
                                      ),
                                    ),
                                  );
                                },
                                child: _buildFeaturedPropertyCard(
                                  context,
                                  firstListing['title'] as String,
                                  (firstListing['location'] as String).split(',')[0],
                                  firstListing['price'] as String,
                                  firstListing['rating'] as String,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          // Additional featured properties (horizontal scroll)
                          SizedBox(
                            height: 138,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: getFeaturedListings().length > 1 
                                  ? getFeaturedListings().length - 1 
                                  : 0,
                              separatorBuilder: (context, index) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final listing = getFeaturedListings()[index + 1];
                                return SizedBox(
                                  width: 230,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PropertyDetailScreen(
                                            propertyId: listing['id'] as String,
                                            title: listing['title'] as String,
                                            location: listing['location'] as String,
                                            price: listing['price'] as String,
                                            rating: listing['rating'] as String,
                                            type: listing['type'] as PropertyType,
                                            images: (listing['images'] as List).cast<String>(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildServiceCard(
                                      context,
                                      listing['type'] == PropertyType.bnb 
                                          ? Icons.hotel 
                                          : Icons.apartment,
                                      listing['title'] as String,
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Quick Actions section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    // Quick action rows
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildQuickAccessRow(
                            context,
                            icon: Icons.local_laundry_service,
                            label: 'Book Fresh Keja service',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapScreen(
                                    mode: MapMode.laundry,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildQuickAccessRow(
                            context,
                            icon: Icons.home,
                            label: 'Find vacant houses & rentals',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapScreen(
                                    mode: MapMode.properties,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
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
          }
        },
      ),
    );
  }

  // Quick Access Row - icon + label (Spotify style, minimal)
  Widget _buildQuickAccessRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDisabled 
        ? Theme.of(context).textTheme.bodySmall?.color
        : Theme.of(context).colorScheme.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
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
                      color: isDisabled 
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (isDisabled)
              Text(
                'Soon',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                ),
              )
            else
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
                  color: const Color(0xFFFFD700), // Gold for ratings
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
                const Icon(
                  Icons.star,
                  color: AppColors.accent,
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

  // Featured Property card - large card for properties
  Widget _buildFeaturedPropertyCard(
    BuildContext context,
    String title,
    String location,
    String price,
    String rating,
  ) {
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.accent,
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
              ],
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
                  const Icon(
                    Icons.star,
                    color: AppColors.accent,
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
