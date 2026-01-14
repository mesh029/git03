import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/map_screen.dart';
import '../screens/fresh_keja_service_screen.dart';
import '../screens/property_detail_screen.dart';
import '../models/map_mode.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  bool _isScrolling = false;

  // Relevant search suggestions based on app content
  final List<Map<String, dynamic>> _searchSuggestions = [
    {'type': 'service', 'title': 'Fresh Keja', 'subtitle': 'Laundry & Cleaning', 'action': 'fresh_keja'},
    {'type': 'service', 'title': 'Saka Keja', 'subtitle': 'BNBs & Apartments', 'action': 'saka_keja'},
    {'type': 'area', 'title': 'Milimani', 'subtitle': '12 properties, 8 providers', 'action': 'milimani'},
    {'type': 'area', 'title': 'Town Center', 'subtitle': '24 properties, 15 providers', 'action': 'town_center'},
    {'type': 'area', 'title': 'Nyalenda', 'subtitle': '18 properties, 12 providers', 'action': 'nyalenda'},
    {'type': 'property', 'title': '3BR Apartment', 'subtitle': 'Milimani - KSh 15,000/month', 'action': 'property_3br'},
    {'type': 'service', 'title': 'Laundry Service', 'subtitle': 'Wash & Fold', 'action': 'laundry'},
    {'type': 'service', 'title': 'House Cleaning', 'subtitle': 'Vacuuming & More', 'action': 'cleaning'},
  ];

  List<Map<String, dynamic>> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = _searchSuggestions;
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = _searchSuggestions;
      } else {
        _filteredSuggestions = _searchSuggestions
            .where((item) =>
                item['title'].toString().toLowerCase().contains(query) ||
                item['subtitle'].toString().toLowerCase().contains(query))
            .toList();
      }
      // Keep suggestions visible when typing
      if (_focusNode.hasFocus) {
        _showSuggestions = _filteredSuggestions.isNotEmpty;
      }
    });
  }

  void _onFocusChanged() {
    // Keep suggestions visible if focus is on search field or if user is scrolling
    setState(() {
      _showSuggestions = _focusNode.hasFocus || (_isScrolling && _filteredSuggestions.isNotEmpty);
    });
  }

  void _handleSuggestionTap(Map<String, dynamic> suggestion) {
    final action = suggestion['action'] as String;
    
    switch (action) {
      case 'fresh_keja':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FreshKejaServiceScreen()),
        );
        break;
      case 'saka_keja':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(
              mode: MapMode.properties,
              data: {'service': 'Saka Keja', 'type': 'all'},
            ),
          ),
        );
        break;
      case 'laundry':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(
              mode: MapMode.laundry,
            ),
          ),
        );
        break;
      case 'cleaning':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(
              mode: MapMode.cleaning,
            ),
          ),
        );
        break;
      case 'milimani':
      case 'town_center':
      case 'nyalenda':
        final areaName = action
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              mode: MapMode.properties,
              data: {'area': areaName},
            ),
          ),
        );
        break;
      case 'property_3br':
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
        break;
    }
    
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search properties, services, areas...',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        // Suggestions dropdown
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          GestureDetector(
            onTap: () {
              // Prevent tap from dismissing dropdown
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
                child: _buildSuggestionsList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    // Calculate approximate height per item (ListTile with padding)
    const double itemHeight = 72.0; // Approximate height per item
    const double maxHeight = 300.0;
    final int itemCount = _filteredSuggestions.length;
    final double calculatedHeight = (itemCount * itemHeight).clamp(0.0, maxHeight);
    final bool needsScrolling = (itemCount * itemHeight) > maxHeight;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Track scrolling state to prevent dropdown from disappearing
        if (notification is ScrollStartNotification) {
          setState(() {
            _isScrolling = true;
          });
        } else if (notification is ScrollEndNotification) {
          // Small delay before allowing focus changes to hide suggestions
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _isScrolling = false;
              });
            }
          });
        }
        return false;
      },
      child: SizedBox(
        height: calculatedHeight,
        child: ListView.separated(
          shrinkWrap: false,
          physics: needsScrolling 
              ? const BouncingScrollPhysics() 
              : const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          itemBuilder: (context, index) {
            final suggestion = _filteredSuggestions[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(
                _getIconForType(suggestion['type']),
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                suggestion['title'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              subtitle: Text(
                suggestion['subtitle'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              onTap: () => _handleSuggestionTap(suggestion),
            );
          },
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'service':
        return Icons.build_circle;
      case 'property':
        return Icons.home;
      case 'area':
        return Icons.location_on;
      default:
        return Icons.search;
    }
  }
}
