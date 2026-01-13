import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'map_screen.dart';
import 'property_detail_screen.dart';
import 'fresh_keja_service_screen.dart';
import '../models/map_mode.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top section with gradient
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xFFFAFAFA),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header with greeting and profile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // "Good morning," text
                              Text(
                                'Good morning,',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF818181),
                                ),
                              ),
                              const SizedBox(height: 5),
                              // "Meshack" title
                              Text(
                                'Meshack',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Location line
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Color(0xFF818181),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Kisumu – Milimani',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF818181),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Dark mode toggle and profile
                        Row(
                          children: [
                            // Dark mode toggle
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, _) {
                                return Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      themeProvider.isDarkMode
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                      color: Theme.of(context).iconTheme.color,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      themeProvider.toggleTheme();
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            // Profile avatar
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0373F3).withValues(alpha: 0.1),
                                border: Border.all(
                                  color: const Color(0xFF0373F3).withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF0373F3),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search bar and filter
                    Row(
                      children: [
                        // Search bar
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE9E9E9),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 18),
                                Icon(
                                  Icons.search,
                                  size: 24,
                                  color: const Color(0xFFA9A9A9),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    'Where are you going or what do you need?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFA9A9A9),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 17),
                        // Filter button
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF0373F3),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Quick Access section
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0),
                      child: Text(
                        'Quick Access',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Horizontal scrollable service cards - using Figma dimensions (230x138)
                    SizedBox(
                      height: 138,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                        children: [
                          // Fresh Keja - Highlighted
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FreshKejaServiceScreen(),
                                ),
                              );
                            },
                            child: _buildServiceCard(
                              Icons.local_laundry_service,
                              'Fresh Keja',
                              const Color(0xFF0373F3),
                              isActive: true,
                            ),
                          ),
                          const SizedBox(width: 25),
                          // Saka Keja - Highlighted
                          GestureDetector(
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
                            child: _buildServiceCard(
                              Icons.home,
                              'Saka Keja',
                              const Color(0xFF0373F3),
                              isActive: true,
                            ),
                          ),
                          const SizedBox(width: 25),
                          // RideX - Dev mode
                          GestureDetector(
                            onTap: () {
                              if (false) { // Disabled for now
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MapScreen(
                                      mode: MapMode.rides,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: _buildServiceCard(
                              Icons.directions_car,
                              'RideX',
                              const Color(0xFF9CA3AF),
                              isActive: false,
                            ),
                          ),
                          const SizedBox(width: 25),
                          // TukTuk Express - Dev mode
                          GestureDetector(
                            onTap: () {
                              if (false) { // Disabled for now
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MapScreen(
                                      mode: MapMode.rides,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: _buildServiceCard(
                              Icons.moped,
                              'TukTuk Express',
                              const Color(0xFF9CA3AF),
                              isActive: false,
                            ),
                          ),
                          const SizedBox(width: 25),
                          // CycleX - Dev mode
                          GestureDetector(
                            onTap: () {
                              if (false) { // Disabled for now
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MapScreen(
                                      mode: MapMode.rides,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: _buildServiceCard(
                              Icons.two_wheeler,
                              'CycleX',
                              const Color(0xFF9CA3AF),
                              isActive: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Popular Services section
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0),
                      child: Text(
                        'Popular Services',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Popular services cards - fixed overflow by reducing padding
                    SizedBox(
                      height: 138,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                        children: [
                          GestureDetector(
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
                            child: _buildPopularServiceCard(
                              'Fresh Keja',
                              'laundry & house cleaning',
                              '4.8',
                              Icons.local_laundry_service,
                              const Color(0xFF0373F3),
                            ),
                          ),
                          const SizedBox(width: 25),
                          GestureDetector(
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
                            child: _buildPopularServiceCard(
                              'Saka Keja',
                              'BNBs & apartments',
                              '4.9',
                              Icons.home,
                              const Color(0xFF0373F3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Service Areas section
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0),
                      child: Text(
                        'Service Areas',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Service areas cards - Kisumu neighborhoods
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.0),
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
                    const SizedBox(height: 30),
                    // Featured Listings section
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0),
                      child: Text(
                        'Featured Listings',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Featured listings - properties and services
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.0),
                      child: Column(
                        children: [
                          // Featured property (large card) - tappable to detail screen
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDetailScreen(
                                    propertyId: '3br_apartment_milimani',
                                    title: '3BR Apartment',
                                    location: 'Milimani, Kisumu',
                                    price: 'KSh 15,000/month',
                                    rating: '4.8',
                                    type: PropertyType.apartment,
                                    images: [
                                      'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
                                      'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
                                      'https://www.figma.com/api/mcp/asset/872fc196-1cb2-42e8-84b0-aa58f49abd5e',
                                      'https://www.figma.com/api/mcp/asset/36b3c108-6c7b-47dd-8836-3cfe30bafb86',
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: _buildFeaturedPropertyCard(
                              '3BR Apartment',
                              'Milimani',
                              'KSh 15,000/month',
                              '4.8',
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Service providers (smaller cards)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
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
                                  child: _buildFeaturedServiceCard(
                                    'Fresh Keja Pro',
                                    'Same-day service',
                                    '4.9',
                                    Icons.local_laundry_service,
                                    const Color(0xFF0373F3),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MapScreen(
                                          mode: MapMode.cleaning,
                                          data: {'service': 'Elite Cleaning'},
                                        ),
                                      ),
                                    );
                                  },
                                  child: _buildFeaturedServiceCard(
                                    'Elite Cleaning',
                                    'House cleaning',
                                    '4.7',
                                    Icons.cleaning_services,
                                    const Color(0xFF0373F3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Recent / Quick Actions section
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0),
                      child: Text(
                        'Quick Actions',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Quick action cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.0),
                      child: Column(
                        children: [
                          GestureDetector(
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
                            child: _buildQuickActionCard(
                              Icons.local_laundry_service,
                              'Book Fresh Keja service',
                              const Color(0xFF0373F3),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
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
                            child: _buildQuickActionCard(
                              Icons.home,
                              'Find vacant houses & rentals',
                              const Color(0xFF0373F3),
                            ),
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
          // Handle navigation
          if (index == 1) {
            // Services - could navigate to services screen
          }
        },
      ),
    );
  }

  // Service cards - using exact Figma dimensions: 230x138
  Widget _buildServiceCard(IconData icon, String label, Color color, {bool isActive = true}) {
    return Container(
      width: 230,
      height: 138,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                color: (isActive ? color : const Color(0xFF9CA3AF)).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? color : const Color(0xFF9CA3AF),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.black : const Color(0xFF9CA3AF),
                  ),
                ),
                if (!isActive) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Soon',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFFF59E0B),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
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
    String neighborhood,
    int propertyCount,
    int serviceProviderCount,
    String imageUrl,
  ) {
    return Container(
      width: 142,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFC4C4C4),
                  child: const Icon(
                    Icons.image,
                    color: Colors.white,
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
                    Colors.black.withOpacity(0.7),
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
                        style: GoogleFonts.andika(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.home,
                            size: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$propertyCount properties',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
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
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$serviceProviderCount providers',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
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
    String title,
    String location,
    String price,
    String rating,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0373F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.home,
              color: Color(0xFF0373F3),
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
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
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
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0373F3),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF59E0B),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
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
            color: const Color(0xFF9CA3AF),
            size: 24,
          ),
        ],
      ),
    );
  }

  // Featured Service card - smaller card for service providers
  Widget _buildFeaturedServiceCard(
    String providerName,
    String availability,
    String rating,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                    color: Color(0xFFF59E0B),
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    rating,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            providerName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            availability,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(IconData icon, String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: const Color(0xFF9CA3AF),
            size: 24,
          ),
        ],
      ),
    );
  }

}
