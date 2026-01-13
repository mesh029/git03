import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/map_mode.dart';
import '../../screens/property_detail_screen.dart';

class PropertyMapBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? data;

  const PropertyMapBottomSheet({super.key, this.data});

  @override
  State<PropertyMapBottomSheet> createState() => _PropertyMapBottomSheetState();
}

class _PropertyMapBottomSheetState extends State<PropertyMapBottomSheet> {
  PropertyType _selectedType = PropertyType.all;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property type selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            children: [
              _buildTypeChip(PropertyType.all),
              const SizedBox(width: 12),
              _buildTypeChip(PropertyType.bnb),
              const SizedBox(width: 12),
              _buildTypeChip(PropertyType.apartment),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Property cards list
        SizedBox(
          height: 166,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            children: _getFilteredProperties().map((property) {
              return Padding(
                padding: const EdgeInsets.only(right: 26.0),
                child: _buildPropertyCard(
                  property['title']!,
                  property['rating']!,
                  property['priceLabel']!,
                  property['price']!,
                  property['imageUrl']!,
                  property['type'] as PropertyType,
                  isFavorited: property['isFavorited'] as bool,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(PropertyType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0373F3).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0373F3)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == PropertyType.bnb
                  ? Icons.hotel
                  : type == PropertyType.apartment
                      ? Icons.apartment
                      : Icons.home,
              size: 16,
              color: isSelected
                  ? const Color(0xFF0373F3)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF0373F3)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredProperties() {
    final allProperties = [
      {
        'title': 'Sunset evening avenue',
        'rating': '4.0',
        'priceLabel': 'from',
        'price': '\$299 / night',
        'imageUrl': 'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
        'type': PropertyType.bnb,
        'isFavorited': false,
      },
      {
        'title': 'Milimani BNB',
        'rating': '4.8',
        'priceLabel': 'from',
        'price': '\$150 / night',
        'imageUrl': 'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
        'type': PropertyType.bnb,
        'isFavorited': true,
      },
      {
        'title': '3BR Apartment',
        'rating': '4.5',
        'priceLabel': 'from',
        'price': 'KSh 15,000/month',
        'imageUrl': 'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
        'type': PropertyType.apartment,
        'isFavorited': false,
      },
      {
        'title': 'Town Center Studio',
        'rating': '4.2',
        'priceLabel': 'from',
        'price': 'KSh 8,000/month',
        'imageUrl': 'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
        'type': PropertyType.apartment,
        'isFavorited': false,
      },
    ];

    if (_selectedType == PropertyType.all) {
      return allProperties;
    }
    return allProperties
        .where((p) => p['type'] == _selectedType)
        .toList();
  }

  Widget _buildPropertyCard(
    String title,
    String rating,
    String priceLabel,
    String price,
    String imageUrl,
    PropertyType type, {
    bool isFavorited = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(
              propertyId: title.toLowerCase().replaceAll(' ', '_'),
              title: title,
              location: 'Milimani, Kisumu',
              price: price,
              rating: rating,
              type: type,
              images: [
                imageUrl,
                'https://www.figma.com/api/mcp/asset/6c6f1a2c-1f4a-47f7-9bd2-70d2672373a4',
                'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51',
                'https://www.figma.com/api/mcp/asset/872fc196-1cb2-42e8-84b0-aa58f49abd5e',
              ],
            ),
          ),
        );
      },
      child: Container(
      width: 271,
      height: 166,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property image
              Container(
                width: 80,
                height: 138,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFC4C4C4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.network(
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
                      // Property type badge
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: type == PropertyType.bnb
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF0373F3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type.label,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Property details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 2),
                    // Type description
                    Text(
                      type.description,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Rating stars
                    Row(
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: const Icon(
                            Icons.star,
                            size: 14,
                            color: Color(0xFFF59E0B),
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
                    const SizedBox(height: 2),
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
                      ? const Color(0xFFEC4899).withValues(alpha: 0.1)
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
                  onPressed: () {
                    // TODO: Toggle favorite
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
