import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyMapBottomSheet extends StatelessWidget {
  final Map<String, dynamic>? data;

  const PropertyMapBottomSheet({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            color: Colors.black.withValues(alpha: 0.1),
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
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
