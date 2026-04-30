import 'package:flutter/material.dart';

import '../l10n/app_localizations_context.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            // 🔥 Dark mode එකේදී shadow එක ඕනෑවට වඩා තදට පේන්නේ නැති වෙන්න හැදුවා
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        // 🔥 NavBar එකේ පසුබිම theme එක අනුව මාරු වේ (Gemini Dark Grey)
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: isDark ? Colors.white38 : Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home, size: 24),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.track_changes, size: 24),
            label: l10n.navTrack,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.lightbulb, size: 24),
            label: l10n.navAi,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.storefront, size: 24),
            label: l10n.navMarket,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book, size: 24),
            label: l10n.navLearn,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, size: 24),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
