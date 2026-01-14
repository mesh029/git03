import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'map_screen.dart';
import '../models/map_mode.dart';

class FreshKejaServiceScreen extends StatelessWidget {
  const FreshKejaServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
        ),
        title: Text(
          'Fresh Keja',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose a Service',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Select the service you need',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            // Laundry Service - icon + label row
            _buildServiceRow(
              context,
              title: 'Laundry Service',
              description: 'Wash, dry, and fold your clothes',
              icon: Icons.local_laundry_service,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(
                      mode: MapMode.laundry,
                      data: {'service': 'Laundry Service'},
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // House Cleaning Service - icon + label row
            _buildServiceRow(
              context,
              title: 'House Cleaning',
              description: 'Vacuuming, seat cleaning, and more',
              icon: Icons.cleaning_services,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(
                      mode: MapMode.cleaning,
                      data: {'service': 'House Cleaning'},
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Features section
            Text(
              'Why Choose Fresh Keja?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(context, Icons.check_circle, 'Same-day service available'),
            const SizedBox(height: 12),
            _buildFeatureItem(context, Icons.check_circle, 'Professional cleaning'),
            const SizedBox(height: 12),
            _buildFeatureItem(context, Icons.check_circle, 'Affordable pricing'),
            const SizedBox(height: 12),
            _buildFeatureItem(context, Icons.check_circle, 'Trusted by thousands'),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceRow(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
