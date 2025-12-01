// lib/features/dashboard/presentation/widgets/spending_chart.dart
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/dashboard_view.dart';

typedef CategoryTapCallback = void Function(String categoryId, String name);

class SpendingChart extends StatelessWidget {
  final DashboardView view;
  final CategoryTapCallback? onCategoryTap;

  const SpendingChart({
    super.key,
    required this.view,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (view.topCategories.isEmpty) {
      return const Text(
        'No category data yet. Add some expenses!',
        style: TextStyle(color: BudgetaColors.textSecondary),
      );
    }

    final total = view.topCategories.fold<double>(
      0,
      (sum, c) => sum + c.amount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top categories',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        ...view.topCategories.map((c) {
          final percent = total == 0 ? 0.0 : (c.amount / total);
          final label = c.categoryId; // you can map id → name later

          return InkWell(
            onTap: onCategoryTap == null
                ? null
                : () => onCategoryTap!(c.categoryId, label),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(label)),
                      Text('${(percent * 100).toStringAsFixed(0)}%'),
                      const SizedBox(width: 8),
                      Text('${c.amount.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor:
                          BudgetaColors.accentLight.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
