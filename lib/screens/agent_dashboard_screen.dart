import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/map_mode.dart';
import '../models/property_listing.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'agent_listing_form_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';

class AgentDashboardScreen extends StatelessWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Agent - Listings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AgentListingFormScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).cardColor,
        icon: const Icon(Icons.add),
        label: const Text('Add listing'),
      ),
      body: Consumer2<AuthProvider, ListingsProvider>(
        builder: (context, auth, listings, _) {
          if (!auth.isAgent) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text('Access Denied', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text('Agent access required', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }

          final agentId = auth.currentUser!.id;
          final myListings = listings.listingsForAgent(agentId);

          if (myListings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apartment, size: 64, color: Theme.of(context).textTheme.bodySmall?.color),
                    const SizedBox(height: 12),
                    Text('No listings yet', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text('Tap "Add listing" to create the first one', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            itemCount: myListings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final l = myListings[index];
              return _ListingCard(listing: l);
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return AppBottomNavigationBar(
            currentIndex: 4,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 1) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 2) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                  (route) => false,
                );
              } else if (index == 3) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  (route) => false,
                );
              } else if (index == 4) {
                // already here
                return;
              } else if (index == 5) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                  (route) => false,
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final PropertyListing listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingsProvider>(
      builder: (context, listings, _) {
        final icon = listing.type == PropertyType.bnb ? Icons.hotel : Icons.apartment;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listing.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(listing.areaLabel, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 6),
                        Text(listing.priceLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Switch(
                    value: listing.isAvailable,
                    onChanged: (v) => listings.toggleAvailability(listing.id, v),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(listing.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(width: 12),
                  Icon(Icons.trending_up, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text('${listing.traction}', style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AgentListingFormScreen(existing: listing)),
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove listing?'),
                          content: const Text('This will remove it from user view immediately.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        listings.removeListing(listing.id);
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

