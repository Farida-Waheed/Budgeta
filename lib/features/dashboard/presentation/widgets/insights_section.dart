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
        const SizedBox(height: 12),
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

  // Map enum → label + icon
  String _labelForType(InsightType type) {
    switch (type) {
      case InsightType.tip:
        return 'Daily Tip';
      case InsightType.trend:
        return 'Trend';
      default:
        return 'Insight';
    }
  }

  IconData _iconForType(InsightType type) {
    switch (type) {
      case InsightType.tip:
        return Icons.auto_awesome_rounded;
      case InsightType.trend:
        return Icons.trending_up_rounded;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _labelForType(insight.type);
    final icon = _iconForType(insight.type);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: BudgetaColors.accentLight.withValues(alpha: 0.9),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left circular icon like "Coffee Spending Alert"
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  BudgetaColors.accentLight.withValues(alpha: 0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: BudgetaColors.primary,
            ),
          ),
          const SizedBox(width: 12),

          // right: title + label + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: BudgetaColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight.description,
                  style: const TextStyle(
                    color: BudgetaColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
