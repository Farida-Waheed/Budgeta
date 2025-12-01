import 'package:flutter/material.dart';

import '../app/router.dart';
import '../app/theme.dart';
import '../core/models/transaction.dart';
import '../features/tracking/presentation/screens/add_transaction_screen.dart';

class BudgetaBottomNav extends StatefulWidget {
  final int currentIndex;

  const BudgetaBottomNav({super.key, required this.currentIndex});

  @override
  State<BudgetaBottomNav> createState() => _BudgetaBottomNavState();
}

class _BudgetaBottomNavState extends State<BudgetaBottomNav> {
  bool _isAddExpanded = false;

  // ---------------- NAVIGATION ----------------
  void _onTapNav(BuildContext context, int index) {
    // Close add menu when switching tab
    if (_isAddExpanded) {
      setState(() => _isAddExpanded = false);
    }

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

  Future<void> _openAdd(
    BuildContext context, {
    TransactionType? preselectedType,
  }) async {
    setState(() => _isAddExpanded = false);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          preselectedType: preselectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double navHeight = 64;
    const double extraHeight = 140; // enough space for 2 rows

    final bool isTrackingTab = widget.currentIndex == 1;
    const double fabRegionHeight = 96;

    return SizedBox(
      height: navHeight +
          (isTrackingTab ? fabRegionHeight : 30) +
          (isTrackingTab && _isAddExpanded ? extraHeight : 0),
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
                      icon: Icons.list_alt_outlined,
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
                      icon: Icons.psychology_outlined,
                      label: 'Coach',
                    ),
                    _buildNavItem(
                      context,
                      index: 4,
                      icon: Icons.flag_outlined,
                      label: 'Challenges',
                    ),
                    _buildNavItem(
                      context,
                      index: 5,
                      icon: Icons.groups_outlined,
                      label: 'Community',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --------- Add Menu (only on Tracking tab) ----------
          if (isTrackingTab && _isAddExpanded)
            Positioned(
              bottom: navHeight + 56 + 32, // bar + fab + gap
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddRow(
                    context,
                    label: 'Add Income',
                    color: Colors.green.shade600,
                    icon: Icons.arrow_upward,
                    onPressed: () => _openAdd(
                      context,
                      preselectedType: TransactionType.income,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAddRow(
                    context,
                    label: 'Add Expense',
                    color: BudgetaColors.primary,
                    icon: Icons.arrow_downward,
                    onPressed: () => _openAdd(
                      context,
                      preselectedType: TransactionType.expense,
                    ),
                  ),
                ],
              ),
            ),

          // --------- Center FAB ----------
          if (isTrackingTab)
            Positioned(
              bottom: navHeight + 16,
              child: FloatingActionButton(
                heroTag: 'bottom_nav_add',
                backgroundColor: BudgetaColors.primary,
                onPressed: () {
                  setState(() => _isAddExpanded = !_isAddExpanded);
                },
                child: Icon(_isAddExpanded ? Icons.close : Icons.add),
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
    final bool isSelected = widget.currentIndex == index;
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
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddRow(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // FIX deprecation: use withValues instead of withOpacity
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: BudgetaColors.deep,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        FloatingActionButton.small(
          heroTag: 'add_row_$label',
          backgroundColor: color,
          onPressed: onPressed,
          child: Icon(icon),
        ),
      ],
    );
  }
}
