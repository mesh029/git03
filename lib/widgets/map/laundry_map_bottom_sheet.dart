import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

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
      constraints: const BoxConstraints(maxHeight: 400), // Reduced height to show more map
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
          style: Theme.of(context).textTheme.titleMedium,
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
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
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
          style: Theme.of(context).textTheme.titleMedium,
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
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            station['name']!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            station['distance']!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
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
        border: Border.all(color: Theme.of(context).dividerColor),
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total items',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$_totalItems items (~${_estimatedWeight.toStringAsFixed(1)} kg)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
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
              Icon(icon, size: 20, color: Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
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
              color: Theme.of(context).colorScheme.primary,
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Container(
              width: 36,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
              color: Theme.of(context).colorScheme.primary,
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
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight (kg)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_weightKg.toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
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
            activeColor: Theme.of(context).colorScheme.primary,
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
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '50 kg',
                style: Theme.of(context).textTheme.bodySmall,
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
          style: Theme.of(context).textTheme.titleMedium,
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
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double _calculatePrice() {
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

    return basePrice;
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
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'KSh ${basePrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          Text(
            '*Final price may vary',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
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
            ? () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                
                if (authProvider.currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in to book services')),
                  );
                  return;
                }

                final quantity = _inputMethod == QuantityInputMethod.items
                    ? _totalItems
                    : _weightKg.toInt();
                
                final location = _selectedLocation == 'current' 
                    ? 'Current Location' 
                    : (_selectedStation ?? 'Pickup Station');
                
                // Build items list
                final items = <String>[];
                if (_shirts > 0) items.add('$_shirts Shirts');
                if (_pants > 0) items.add('$_pants Pants');
                if (_dresses > 0) items.add('$_dresses Dresses');
                if (_shoes > 0) items.add('$_shoes Shoes');
                if (_bedding > 0) items.add('$_bedding Bedding');
                if (_towels > 0) items.add('$_towels Towels');
                
                final user = authProvider.currentUser!;
                final pickupLocation = _selectedLocation == 'current' ? 'Current Location' : (_selectedStation ?? 'Pickup Station');
                final dropoffLocation = _selectedLocation == 'current' ? 'Current Location' : (_selectedStation ?? 'Drop-off Station');
                
                final order = Order(
                  id: 'order_${DateTime.now().millisecondsSinceEpoch}',
                  userId: user.id,
                  type: OrderType.laundry,
                  status: OrderStatus.pending,
                  details: {
                    'quantity': quantity,
                    'method': _selectedLocation == 'current' ? 'Pickup' : 'Drop-off',
                    'location': location,
                    'pickupLocation': pickupLocation,
                    'dropoffLocation': dropoffLocation,
                    'items': items,
                    'serviceType': _serviceType == 'wash_fold' ? 'Wash & Fold' : 'Dry Clean',
                    'customerName': user.name,
                    'customerEmail': user.email,
                    'customerPhone': user.phone,
                  },
                  createdAt: DateTime.now(),
                  scheduledAt: DateTime.now().add(const Duration(hours: 2)),
                  amount: _calculatePrice(),
                );

                await orderProvider.addOrder(order);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Laundry service booked successfully!'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          'Book Laundry Service',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).cardColor,
          ),
        ),
      ),
    );
  }
}
