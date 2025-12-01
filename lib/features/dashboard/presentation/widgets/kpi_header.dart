// lib/features/dashboard/presentation/widgets/kpi_header.dart
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/dashboard_view.dart';

class KpiHeader extends StatelessWidget {
  final DashboardView view;
  const KpiHeader({super.key, required this.view});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _kpiRow(
          context,
          leftLabel: 'Income',
          leftValue: view.totalIncome,
          leftColor: Colors.green,
          rightLabel: 'Expenses',
          rightValue: view.totalExpenses,
          rightColor: Colors.red,
        ),
        const SizedBox(height: 8),
        _kpiRow(
          context,
          leftLabel: 'Net',
          leftValue: view.net,
          leftColor: view.net >= 0 ? Colors.green : Colors.red,
          rightLabel: 'Left to spend',
          rightValue: view.leftToSpend,
          rightColor: BudgetaColors.deep,
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            label: Text(
              view.isOnTrackThisPeriod
                  ? 'On track this period'
                  : 'You might be overspending',
            ),
            backgroundColor: view.isOnTrackThisPeriod
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            labelStyle: TextStyle(
              color: view.isOnTrackThisPeriod ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _kpiRow(
    BuildContext context, {
    required String leftLabel,
    required double leftValue,
    required Color leftColor,
    required String rightLabel,
    required double rightValue,
    required Color rightColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: _kpiTile(
            label: leftLabel,
            value: leftValue,
            color: leftColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _kpiTile(
            label: rightLabel,
            value: rightValue,
            color: rightColor,
          ),
        ),
      ],
    );
  }

  Widget _kpiTile({
    required String label,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                color: BudgetaColors.textSecondary,
                fontSize: 12,
              )),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(0)} EGP',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
