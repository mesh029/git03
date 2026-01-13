import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum QuantityInputMethod { items, weight }

class LaundryMapBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? data;

  const LaundryMapBottomSheet({super.key, this.data});

  @override
  State<LaundryMapBottomSheet> createState() => _LaundryMapBottomSheetState();
}

class _LaundryMapBottomSheetState extends State<LaundryMapBottomSheet> {
  QuantityInputMethod _inputMethod = QuantityInputMethod.items;
  String _selectedLocation = 'current';
  String? _selectedStation;
  
  // Item-based quantities
  int _shirts = 0;
  int _pants = 0;
  int _dresses = 0;
  int _shoes = 0;
  int _bedding = 0;
  int _towels = 0;
  
  // Weight-based quantity
  double _weightKg = 1.0;
  
  // Service type
  String _serviceType = 'wash_fold'; // 'wash_fold' or 'dry_clean'

  int get _totalItems => _shirts + _pants + _dresses + _shoes + _bedding + _towels;
  double get _estimatedWeight => (_totalItems * 0.3).clamp(0.5, 50.0); // ~0.3kg per item average

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location selection
            _buildLocationSelection(),
            const SizedBox(height: 20),
            // Pickup stations (if not using current location)
            if (_selectedLocation == 'station') _buildPickupStations(),
            const SizedBox(height: 20),
            // Quantity selection method
            _buildQuantityMethodSelector(),
            const SizedBox(height: 20),
            // Quantity input (items or weight)
            _buildQuantityInput(),
            const SizedBox(height: 20),
            // Service type
            _buildServiceTypeSelection(),
            const SizedBox(height: 20),
            // Price estimate
            _buildPriceEstimate(),
            const SizedBox(height: 20),
            // Book button
            _buildBookButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Location',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLocationOption(
                'Current Location',
                Icons.my_location,
                'current',
                _selectedLocation == 'current',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLocationOption(
                'Pickup Station',
                Icons.store,
                'station',
                _selectedLocation == 'station',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationOption(
    String label,
    IconData icon,
    String value,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = value;
          if (value == 'current') {
            _selectedStation = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0373F3).withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0373F3)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF0373F3)
                  : const Color(0xFF9CA3AF),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
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

  Widget _buildPickupStations() {
    final stations = [
      {'name': 'Milimani Station', 'distance': '0.5 km'},
      {'name': 'Town Center Station', 'distance': '1.2 km'},
      {'name': 'Nyalenda Station', 'distance': '2.1 km'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Pickup Station',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...stations.map((station) {
          final isSelected = _selectedStation == station['name'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStation = station['name'];
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0373F3).withValues(alpha: 0.1)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0373F3)
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      color: isSelected
                          ? const Color(0xFF0373F3)
                          : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station['name']!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
                            ),
                          ),
                          Text(
                            station['distance']!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF0373F3),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildQuantityMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: _buildMethodTab(
                  'By Items',
                  Icons.checkroom,
                  QuantityInputMethod.items,
                ),
              ),
              Expanded(
                child: _buildMethodTab(
                  'By Weight',
                  Icons.scale,
                  QuantityInputMethod.weight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodTab(String label, IconData icon, QuantityInputMethod method) {
    final isSelected = _inputMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _inputMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF0373F3)
                  : const Color(0xFF9CA3AF),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
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

  Widget _buildQuantityInput() {
    if (_inputMethod == QuantityInputMethod.items) {
      return _buildItemCountInput();
    } else {
      return _buildWeightInput();
    }
  }

  Widget _buildItemCountInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          _buildItemCounter('Shirts', _shirts, (value) {
            setState(() => _shirts = value);
          }, Icons.checkroom),
          const Divider(height: 24),
          _buildItemCounter('Pants', _pants, (value) {
            setState(() => _pants = value);
          }, Icons.checkroom),
          const Divider(height: 24),
          _buildItemCounter('Dresses', _dresses, (value) {
            setState(() => _dresses = value);
          }, Icons.checkroom),
          const Divider(height: 24),
          _buildItemCounter('Shoes', _shoes, (value) {
            setState(() => _shoes = value);
          }, Icons.shopping_bag),
          const Divider(height: 24),
          _buildItemCounter('Bedding', _bedding, (value) {
            setState(() => _bedding = value);
          }, Icons.bed),
          const Divider(height: 24),
          _buildItemCounter('Towels', _towels, (value) {
            setState(() => _towels = value);
          }, Icons.dry_cleaning),
          if (_totalItems > 0) ...[
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0373F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total items',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
                    ),
                  ),
                  Text(
                    '$_totalItems items (~${_estimatedWeight.toStringAsFixed(1)} kg)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0373F3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemCounter(
    String label,
    int value,
    Function(int) onChanged,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 0
                  ? () => onChanged(value - 1)
                  : null,
              color: const Color(0xFF0373F3),
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Container(
              width: 36,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
              color: const Color(0xFF0373F3),
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight (kg)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0373F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_weightKg.toStringAsFixed(1)} kg',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0373F3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Slider(
            value: _weightKg,
            min: 0.5,
            max: 50.0,
            divisions: 99,
            activeColor: const Color(0xFF0373F3),
            onChanged: (value) {
              setState(() {
                _weightKg = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0.5 kg',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                '50 kg',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Type',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildServiceOption(
                'Wash & Fold',
                Icons.local_laundry_service,
                'wash_fold',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildServiceOption(
                'Dry Clean',
                Icons.cleaning_services,
                'dry_clean',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceOption(String label, IconData icon, String value) {
    final isSelected = _serviceType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _serviceType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0373F3).withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0373F3)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0373F3), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceEstimate() {
    double basePrice = 0;
    if (_inputMethod == QuantityInputMethod.items) {
      // Item-based is more expensive due to mixed weights (heavy + light clothes)
      basePrice = _totalItems * 80; // KSh 80 per item (more expensive)
    } else {
      // Weight-based is cheaper - straightforward pricing
      basePrice = _weightKg * 150; // KSh 150 per kg (cheaper)
    }
    
    if (_serviceType == 'dry_clean') {
      basePrice *= 1.5; // Dry clean is 50% more
    }

    if (basePrice == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0373F3).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Price',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'KSh ${basePrice.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0373F3),
                ),
              ),
            ],
          ),
          Text(
            '*Final price may vary',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    final isValid = (_selectedLocation == 'current' ||
            (_selectedLocation == 'station' && _selectedStation != null)) &&
        ((_inputMethod == QuantityInputMethod.items && _totalItems > 0) ||
            (_inputMethod == QuantityInputMethod.weight && _weightKg > 0));

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isValid
            ? () {
                final quantity = _inputMethod == QuantityInputMethod.items
                    ? '$_totalItems items'
                    : '${_weightKg.toStringAsFixed(1)} kg';
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking laundry: $quantity, ${_serviceType == 'wash_fold' ? 'Wash & Fold' : 'Dry Clean'} at ${_selectedLocation == 'current' ? 'current location' : _selectedStation}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0373F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          'Book Laundry Service',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).cardColor,
          ),
        ),
      ),
    );
  }
}
