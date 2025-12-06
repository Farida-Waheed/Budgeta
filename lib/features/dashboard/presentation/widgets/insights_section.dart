import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/insight.dart';

class InsightsSection extends StatelessWidget {
  final List<Insight> insights;

  const InsightsSection({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Insights 💡',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            for (final i in insights) _InsightCard(insight: i),
          ],
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Insight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    // We keep styling simple & safe (we don't rely on enum names here)
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BudgetaColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: BudgetaColors.deep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.description,
            style: const TextStyle(
              fontSize: 12,
              color: BudgetaColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
