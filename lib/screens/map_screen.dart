import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB), // Map background color
            ),
            child: Image.network(
              'https://www.figma.com/api/mcp/asset/26b19d5c-d5e0-479a-899f-e50a8e0022d2',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE5E7EB),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 64,
                          color: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Map View',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Location pins on map
          ..._buildLocationPins(),
          // Top navigation bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
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
                        color: Colors.white,
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
                          Icon(
                            Icons.search,
                            size: 22,
                            color: const Color(0xFFAEAEAE),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'Search...',
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0373F3),
                    ),
                    child: IconButton(
                      icon: const Icon(
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
          ),
          // Bottom section with property cards
          Positioned(
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
                    Colors.white.withOpacity(0.95),
                    Colors.white,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // "Location targeting" title
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        'Location targeting',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Horizontal scrollable property cards
                    SizedBox(
                      height: 166,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                        children: [
                          _buildPropertyCard(
                            'Sunset evening avenue',
                            '4.0',
                            'from',
                            '\$299 / night',
                            'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
                            isFavorited: false,
                          ),
                          const SizedBox(width: 26),
                          _buildPropertyCard(
                            'Hanging adsasd\nasdasdasd',
                            '4.0',
                            'from',
                            '\$199/night',
                            'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
                            isFavorited: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLocationPins() {
    // Location pins positioned on the map (relative positions)
    // These will be positioned relative to screen size
    return [
      _buildLocationPin(left: 181, top: 300),
      _buildLocationPin(left: 148, top: 213),
      _buildLocationPin(left: 121, top: 367),
      _buildLocationPin(left: 318, top: 450),
      _buildLocationPin(left: 53, top: 211),
      _buildLocationPin(left: 337, top: 329),
      _buildLocationPin(left: 243, top: 316),
      _buildLocationPin(left: 195, top: 448),
    ];
  }

  Widget _buildLocationPin({required double left, required double top}) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0373F3),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildPropertyCard(
    String title,
    String rating,
    String priceLabel,
    String price,
    String imageUrl, {
    bool isFavorited = false,
  }) {
    return Container(
      width: 271,
      height: 166,
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
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            Container(
              width: 80,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFC4C4C4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFC4C4C4),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Property details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Rating stars
                  Row(
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.star,
                          size: 14,
                          color: const Color(0xFFF59E0B),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  // Price label
                  Text(
                    priceLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFAEAEAE),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Favorite button
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFavorited
                    ? const Color(0xFFEC4899).withOpacity(0.1)
                    : Colors.white,
                border: Border.all(
                  color: isFavorited
                      ? const Color(0xFFEC4899)
                      : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: isFavorited
                      ? const Color(0xFFEC4899)
                      : const Color(0xFF9CA3AF),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
