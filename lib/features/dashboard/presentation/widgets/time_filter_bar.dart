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
    final labels = ['Last 30 days', 'This month', 'All time'];

    return Wrap(
      spacing: 8,
      children: List.generate(labels.length, (i) {
        final isSelected = i == _selectedIndex;
        return ChoiceChip(
          label: Text(labels[i]),
          selected: isSelected,
          selectedColor: BudgetaColors.primary,
          backgroundColor:
              BudgetaColors.accentLight.withValues(alpha: 0.4),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : BudgetaColors.deep,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (_) => _updateSelection(i),
        );
      }),
    );
  }
}
