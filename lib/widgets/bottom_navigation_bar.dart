import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isAdmin = authProvider.isAdmin;
        final isAgent = authProvider.isAgent;
        
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(context, Icons.home, 'Home', 0),
                  _buildNavItem(context, Icons.build_circle, 'Services', 1),
                  _buildNavItem(context, Icons.receipt_long, 'Orders', 2),
                  _buildNavItem(context, Icons.person, 'Profile', 3),
                  if (isAdmin)
                    _buildNavItem(context, Icons.admin_panel_settings, 'Admin', 4)
                  else if (isAgent)
                    _buildNavItem(context, Icons.badge, 'Agent', 4),
                  _buildNavItem(context, Icons.chat_bubble_outline, 'Messages', 5),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFFBCBCBC),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFFBCBCBC),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
