// lib/features/dashboard/presentation/widgets/time_filter_bar.dart
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../dashboard/data/dashboard_repository.dart';

typedef DashboardFilterCallback = void Function(DashboardFilter filter);

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
  int _selectedIndex = 1; // 0 = week, 1 = month, 2 = 30 days

  void _updateSelection(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        widget.onFilterChanged(DashboardFilter.thisWeek());
        break;
      case 1:
        widget.onFilterChanged(DashboardFilter.currentMonth());
        break;
      case 2:
        widget.onFilterChanged(DashboardFilter.last30Days());
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    // Fire initial value
    widget.onFilterChanged(DashboardFilter.currentMonth());
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['This week', 'This month', 'Last 30 days'];

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
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (_) => _updateSelection(i),
        );
      }),
    );
  }
}
