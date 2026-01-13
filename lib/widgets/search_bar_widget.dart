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
  String _selectedFilter = 'all'; // 'all', 'properties', 'services', 'areas'

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
        _filteredSuggestions = _getFilteredSuggestions(_selectedFilter);
      } else {
        _filteredSuggestions = _searchSuggestions
            .where((item) =>
                item['title'].toString().toLowerCase().contains(query) ||
                item['subtitle'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });
  }

  List<Map<String, dynamic>> _getFilteredSuggestions(String filter) {
    if (filter == 'all') return _searchSuggestions;
    return _searchSuggestions.where((item) => item['type'] == filter).toList();
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('All', 'all', Icons.apps),
            _buildFilterOption('Properties', 'properties', Icons.home),
            _buildFilterOption('Services', 'services', Icons.build_circle),
            _buildFilterOption('Areas', 'areas', Icons.location_on),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF0373F3) : Theme.of(context).iconTheme.color),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? const Color(0xFF0373F3) : Theme.of(context).textTheme.titleMedium?.color,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF0373F3))
          : null,
      onTap: () {
        setState(() {
          _selectedFilter = value;
          _filteredSuggestions = _getFilteredSuggestions(value);
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search properties, services, areas...',
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF9CA3AF),
                fontSize: 16,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF0373F3),
                size: 24,
              ),
              suffixIcon: GestureDetector(
                onTap: _showFilterDialog,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0373F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Theme.of(context).cardColor,
                    size: 20,
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        // Suggestions dropdown
        if (_showSuggestions && _filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  leading: Icon(
                    _getIconForType(suggestion['type']),
                    color: const Color(0xFF0373F3),
                  ),
                  title: Text(
                    suggestion['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  subtitle: Text(
                    suggestion['subtitle'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  onTap: () => _handleSuggestionTap(suggestion),
                );
              },
            ),
          ),
      ],
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
