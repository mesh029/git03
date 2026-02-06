import 'package:flutter/material.dart';
import '../models/map_mode.dart';
import '../theme/app_theme.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  final String title;
  final String location;
  final String price;
  final String rating;
  final PropertyType type;
  final List<String> images;
  final Map<String, dynamic>? details;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    required this.title,
    required this.location,
    required this.price,
    required this.rating,
    required this.type,
    required this.images,
    this.details,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isFavorited = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with image carousel
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? const Color(0xFFEC4899) : Theme.of(context).iconTheme.color,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorited = !_isFavorited;
                  });
                },
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: Icon(Icons.share, color: Theme.of(context).iconTheme.color),
                onPressed: () {},
                padding: EdgeInsets.zero,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property type badge - minimal
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.type == PropertyType.bnb
                          ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.14)
                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.type.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.type == PropertyType.bnb
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.location,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rating and price
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.rating,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(24 reviews)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.price,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Divider
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 24),
                  // About section
                  Text(
                    'About this place',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Beautiful ${widget.type == PropertyType.bnb ? "bed and breakfast" : "apartment"} located in the heart of ${widget.location}. Perfect for ${widget.type == PropertyType.bnb ? "short-term stays" : "long-term rentals"}. Modern amenities and excellent location.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Amenities
                  Text(
                    'Amenities',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildAmenitiesGrid(),
                  const SizedBox(height: 32),
                  // Location map preview
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildLocationPreview(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        // PageView for images
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return Image.network(
              widget.images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).dividerColor,
                  child: Icon(
                    Icons.image,
                    size: 64,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                  ),
                );
              },
            );
          },
        ),
        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Theme.of(context).textTheme.titleLarge?.color?.withOpacity(0.3) ?? Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        // Image indicators
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Theme.of(context).cardColor
                      : Theme.of(context).cardColor.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid() {
    final amenities = [
      {'icon': Icons.wifi, 'label': 'WiFi'},
      {'icon': Icons.local_parking, 'label': 'Parking'},
      {'icon': Icons.ac_unit, 'label': 'AC'},
      {'icon': Icons.kitchen, 'label': 'Kitchen'},
      {'icon': Icons.water_drop, 'label': 'Water'},
      {'icon': Icons.security, 'label': 'Security'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        return Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                amenities[index]['icon'] as IconData,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                amenities[index]['label'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Map placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://www.figma.com/api/mcp/asset/26b19d5c-d5e0-479a-899f-e50a8e0022d2',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).dividerColor,
                  child: Icon(
                    Icons.map,
                    size: 48,
                    color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
          ),
          // Location pin
          Center(
            child: Icon(
              Icons.location_on,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Contact button
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Contact',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Book button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.type == PropertyType.bnb ? 'Book Now' : 'Apply Now',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
