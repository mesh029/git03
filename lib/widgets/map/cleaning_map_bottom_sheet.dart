import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
              ? const Color(0xFF0373F3).withValues(alpha: 0.1)
              : Colors.white,
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
    // For cleaning, this would be address input
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Enter address',
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF0373F3)),
        ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Services',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _selectedServices.length,
          itemBuilder: (context, index) {
            final service = _selectedServices.keys.elementAt(index);
            final isSelected = _selectedServices[service]!;
            return _buildServiceCheckbox(service, isSelected);
          },
        ),
      ],
    );
  }

  Widget _buildServiceCheckbox(String service, bool isSelected) {
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
              ? const Color(0xFF0373F3).withValues(alpha: 0.1)
              : Colors.white,
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
              icons[service],
              size: 20,
              color: isSelected
                  ? const Color(0xFF0373F3)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                labels[service]!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0373F3)
                      : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 18,
                color: Color(0xFF0373F3),
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
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
              ? const Color(0xFF0373F3).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0373F3)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? const Color(0xFF0373F3)
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceEstimate() {
    final selectedCount = _selectedServices.values.where((v) => v).length;
    if (selectedCount == 0) return const SizedBox.shrink();

    double basePrice = selectedCount * 500; // KSh 500 per service
    if (_frequency == 'weekly') {
      basePrice *= 0.8; // 20% discount for weekly
    } else if (_frequency == 'monthly') {
      basePrice *= 0.7; // 30% discount for monthly
    }

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
          if (_frequency != 'one_time')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _frequency == 'weekly' ? '20% off' : '30% off',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
            ? () {
                final services = _selectedServices.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .join(', ');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking cleaning: $selectedCount service(s) - $services, $_frequency at ${_selectedLocation == 'current' ? 'your location' : 'other address'}',
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
          'Book Cleaning Service',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
