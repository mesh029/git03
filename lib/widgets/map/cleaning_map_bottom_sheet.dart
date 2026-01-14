import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';

class CleaningMapBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? data;

  const CleaningMapBottomSheet({super.key, this.data});

  @override
  State<CleaningMapBottomSheet> createState() => _CleaningMapBottomSheetState();
}

class _CleaningMapBottomSheetState extends State<CleaningMapBottomSheet> {
  String _selectedLocation = 'current';
  String? _selectedStation;
  final Map<String, bool> _selectedServices = {
    'vacuuming': false,
    'seat_cleaning': false,
    'general_cleaning': false,
    'deep_cleaning': false,
    'window_cleaning': false,
    'bathroom_cleaning': false,
  };
  String _frequency = 'one_time'; // 'one_time', 'weekly', 'monthly'

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
            // Service selection
            _buildServiceSelection(),
            const SizedBox(height: 20),
            // Frequency selection
            _buildFrequencySelection(),
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
          'Service Location',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLocationOption(
                'My Location',
                Icons.my_location,
                'current',
                _selectedLocation == 'current',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLocationOption(
                'Other Address',
                Icons.location_on,
                'other',
                _selectedLocation == 'other',
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
                  : const Color(0xFF9CA3AF),
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
    // For cleaning, this would be address input
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Enter address',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    final servicePrices = {
      'vacuuming': 500,
      'seat_cleaning': 400,
      'general_cleaning': 600,
      'deep_cleaning': 1200,
      'window_cleaning': 300,
      'bathroom_cleaning': 500,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Services',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: _selectedServices.length,
          itemBuilder: (context, index) {
            final service = _selectedServices.keys.elementAt(index);
            final isSelected = _selectedServices[service]!;
            final price = servicePrices[service] ?? 0;
            return _buildServiceCheckbox(service, isSelected, price);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCheckbox(String service, bool isSelected, int price) {
    final labels = {
      'vacuuming': 'Vacuuming',
      'seat_cleaning': 'Seat Cleaning',
      'general_cleaning': 'General Cleaning',
      'deep_cleaning': 'Deep Cleaning',
      'window_cleaning': 'Window Cleaning',
      'bathroom_cleaning': 'Bathroom Cleaning',
    };

    final icons = {
      'vacuuming': Icons.cleaning_services,
      'seat_cleaning': Icons.chair,
      'general_cleaning': Icons.home,
      'deep_cleaning': Icons.cleaning_services,
      'window_cleaning': Icons.window,
      'bathroom_cleaning': Icons.bathroom,
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedServices[service] = !isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icons[service],
                  size: 18,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    labels[service]!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'KSh $price',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFrequencyOption('One-time', 'one_time'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFrequencyOption('Weekly', 'weekly'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFrequencyOption('Monthly', 'monthly'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencyOption(String label, String value) {
    final isSelected = _frequency == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _frequency = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }

  double _calculatePrice() {
    double basePrice = 0;
    _selectedServices.forEach((service, isSelected) {
      if (isSelected) {
        switch (service) {
          case 'vacuuming':
            basePrice += 500;
            break;
          case 'seat_cleaning':
            basePrice += 800;
            break;
          case 'general_cleaning':
            basePrice += 1500;
            break;
          case 'deep_cleaning':
            basePrice += 2500;
            break;
          case 'window_cleaning':
            basePrice += 600;
            break;
          case 'bathroom_cleaning':
            basePrice += 700;
            break;
        }
      }
    });

    if (_frequency == 'weekly') {
      basePrice *= 0.8; // 20% discount for weekly
    } else if (_frequency == 'monthly') {
      basePrice *= 0.7; // 30% discount for monthly
    }

    return basePrice;
  }

  Widget _buildPriceEstimate() {
    final selectedCount = _selectedServices.values.where((v) => v).length;
    if (selectedCount == 0) return const SizedBox.shrink();

    // Calculate price based on selected services
    final servicePrices = {
      'vacuuming': 500,
      'seat_cleaning': 400,
      'general_cleaning': 600,
      'deep_cleaning': 1200,
      'window_cleaning': 300,
      'bathroom_cleaning': 500,
    };

    double basePrice = 0;
    _selectedServices.forEach((service, isSelected) {
      if (isSelected) {
        basePrice += servicePrices[service] ?? 0;
      }
    });

    if (_frequency == 'weekly') {
      basePrice *= 0.8; // 20% discount for weekly
    } else if (_frequency == 'monthly') {
      basePrice *= 0.7; // 30% discount for monthly
    }

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
          if (_frequency != 'one_time')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _frequency == 'weekly' ? '20% off' : '30% off',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).cardColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    final selectedCount = _selectedServices.values.where((v) => v).length;
    final isValid = (_selectedLocation == 'current' ||
            (_selectedLocation == 'other')) &&
        selectedCount > 0;

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

                final selectedServiceList = _selectedServices.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .toList();
                
                final primaryService = selectedServiceList.isNotEmpty
                    ? selectedServiceList[0]
                    : 'general_cleaning';
                
                // Map service keys to readable names
                final serviceNameMap = {
                  'vacuuming': 'Vacuuming',
                  'seat_cleaning': 'Seat Cleaning',
                  'general_cleaning': 'General Cleaning',
                  'deep_cleaning': 'Deep Cleaning',
                  'window_cleaning': 'Window Cleaning',
                  'bathroom_cleaning': 'Bathroom Cleaning',
                };
                
                final serviceName = serviceNameMap[primaryService] ?? 'General Cleaning';
                final location = _selectedLocation == 'current' 
                    ? 'Current Location' 
                    : 'Other Address';
                
                // Count rooms (estimate based on service type)
                final rooms = primaryService == 'deep_cleaning' ? 3 : 2;
                
                final user = authProvider.currentUser!;
                final order = Order(
                  id: 'order_${DateTime.now().millisecondsSinceEpoch}',
                  userId: user.id,
                  type: OrderType.cleaning,
                  status: OrderStatus.pending,
                  details: {
                    'service': serviceName,
                    'location': location,
                    'pickupLocation': location,
                    'dropoffLocation': location,
                    'rooms': rooms,
                    'frequency': _frequency == 'one_time' ? 'One-time' : 
                                 _frequency == 'weekly' ? 'Weekly' : 'Monthly',
                    'services': selectedServiceList,
                    'customerName': user.name,
                    'customerEmail': user.email,
                    'customerPhone': user.phone,
                  },
                  createdAt: DateTime.now(),
                  scheduledAt: DateTime.now().add(const Duration(days: 1)),
                  amount: _calculatePrice(),
                );

                await orderProvider.addOrder(order);
                
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cleaning service booked successfully!'),
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
          'Book Cleaning Service',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).cardColor,
          ),
        ),
      ),
    );
  }
}
