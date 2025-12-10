import 'package:flutter/material.dart';

import '../app/router.dart';
import '../app/theme.dart';

class BudgetaBottomNav extends StatefulWidget {
  /// The tab that is *logically* active for navigation.
  /// Used to prevent re-pushing the same route.
  final int currentIndex;

  /// Optional: force a specific tab to appear selected (colored),
  /// even if [currentIndex] is different.
  /// Example: in Recurring screen → currentIndex = -1, highlightIndex = 1.
  final int? highlightIndex;

  const BudgetaBottomNav({
    super.key,
    required this.currentIndex,
    this.highlightIndex,
  });

  @override
  State<BudgetaBottomNav> createState() => _BudgetaBottomNavState();
}

class _BudgetaBottomNavState extends State<BudgetaBottomNav> {
  // ---------------- NAVIGATION ----------------
  void _onTapNav(BuildContext context, int index) {
    // If we are already on that tab (by navigation index), do nothing.
    if (index == widget.currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.tracking);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.goals);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.coach);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.challenges);
        break;
      case 5:
        Navigator.pushReplacementNamed(context, AppRoutes.community);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double navHeight = 64;

    return SizedBox(
      height: navHeight + 20, // small padding above bar
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // --------- Bottom Nav Bar ----------
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomAppBar(
              color: Colors.white,
              shape: const CircularNotchedRectangle(),
              elevation: 8,
              child: SizedBox(
                height: navHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      index: 0,
                      icon: Icons.grid_view_outlined,
                      label: 'Dashboard',
                    ),
                    _buildNavItem(
                      context,
                      index: 1,
                      icon: Icons.receipt_long, // tracking icon
                      label: 'Tracking',
                    ),
                    _buildNavItem(
                      context,
                      index: 2,
                      icon: Icons.savings_outlined,
                      label: 'Goals',
                    ),
                    _buildNavItem(
                      context,
                      index: 3,
                      icon: Icons.auto_awesome, // AI / coach vibe
                      label: 'Coach',
                    ),
                    _buildNavItem(
                      context,
                      index: 4,
                      icon: Icons.flag_rounded,
                      label: 'Challenges',
                    ),
                    _buildNavItem(
                      context,
                      index: 5,
                      icon: Icons.group,
                      label: 'Community',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------- Helpers ----------------

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    // Selected if either:
    // - this is the active route (currentIndex)
    // - OR caller asked to highlight it (highlightIndex)
    final bool isSelected =
        widget.currentIndex == index || widget.highlightIndex == index;

    final Color color = isSelected ? BudgetaColors.deep : Colors.grey;

    return Expanded(
      child: InkWell(
        onTap: () => _onTapNav(context, index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
