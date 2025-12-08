import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../data/dashboard_repository.dart' as dash_repo;

typedef DashboardFilterCallback = void Function(dash_repo.DashboardFilter);

class TimeFilterBar extends StatefulWidget {
  final DashboardFilterCallback onFilterChanged;

  const TimeFilterBar({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<TimeFilterBar> createState() => _TimeFilterBarState();
}

class _TimeFilterBarState extends State<TimeFilterBar> {
  int _selectedIndex = 1; // 0 = 30 days, 1 = month, 2 = all time

  @override
  void initState() {
    super.initState();
    // Fire initial value
    widget.onFilterChanged(dash_repo.DashboardFilter.currentMonth());
  }

  void _updateSelection(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        widget.onFilterChanged(dash_repo.DashboardFilter.last30Days());
        break;
      case 1:
        widget.onFilterChanged(dash_repo.DashboardFilter.currentMonth());
        break;
      case 2:
        widget.onFilterChanged(dash_repo.DashboardFilter.allTime());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'Last 30 days', 'icon': Icons.auto_graph_rounded},
      {'label': 'This month', 'icon': Icons.calendar_today_rounded},
      {'label': 'All time', 'icon': Icons.history_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = i == _selectedIndex;

          return Padding(
            padding: EdgeInsets.only(right: i == filters.length - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => _updateSelection(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: BudgetaColors.primary
                                .withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFFF4F8B),
                            Color(0xFFB20F4E),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  // 🤍 UI change: unselected background is now clean white
                  color: !isSelected ? Colors.white : null,
                  border: Border.all(
                    width: 1.2,
                    color: isSelected
                        ? BudgetaColors.primary
                        // 🪞 UI change: unselected border uses cardBorder
                        : BudgetaColors.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filters[i]['icon'] as IconData,
                      size: 16,
                      // 🎯 UI change: dark neutral icon when unselected
                      color: isSelected ? Colors.white : BudgetaColors.deep,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filters[i]['label'] as String,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : BudgetaColors.deep,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
