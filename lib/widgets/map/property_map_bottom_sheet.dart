import 'package:flutter/material.dart';
import '../../models/map_mode.dart';
import '../../screens/property_detail_screen.dart';
import '../../screens/home_screen.dart'; // For AppColors
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';

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
    return Consumer<ListingsProvider>(
      builder: (context, listingsProvider, _) {
        final listings = listingsProvider.availableByType(_selectedType);
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                itemCount: listings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 26),
                itemBuilder: (context, index) {
                  final l = listings[index];
                  final imageUrl = l.images.isNotEmpty
                      ? l.images.first
                      : 'https://www.figma.com/api/mcp/asset/436a2986-be9d-40e9-a2ff-84927cb2dd51';
                  return _buildPropertyCard(
                    l.title,
                    l.rating.toStringAsFixed(1),
                    'from',
                    l.priceLabel,
                    imageUrl,
                    l.type,
                    isFavorited: false,
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
                  );
                },
              ),
            ),
          ],
        );
      },
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
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: 1,
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
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Properties are now sourced from ListingsProvider (agent-managed).

  Widget _buildPropertyCard(
    String title,
    String rating,
    String priceLabel,
    String price,
    String imageUrl,
    PropertyType type, {
    bool isFavorited = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: 271,
      height: 166,
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
                            child: Icon(
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
                                ? AppColors.accent
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type.label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).cardColor,
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
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Type description
                    Text(
                      type.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
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
                            color: AppColors.accent,
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    // Price label
                    Text(
                      priceLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    // Price
                    Text(
                      price,
                      style: Theme.of(context).textTheme.bodyMedium,
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
                      : Theme.of(context).cardColor,
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
