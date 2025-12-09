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
        Column(children: [for (final i in insights) _InsightCard(insight: i)]),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Insight insight;

  const _InsightCard({required this.insight});

  Color _colorForType(InsightType type) {
    switch (type) {
      case InsightType.alert:
      case InsightType.overspending:
        return const Color(0xFFEB3B5A); // warm red for alerts
      case InsightType.trend:
        // 💗 updated trend color to pink-friendly
        return const Color(0xFFF75586);
      case InsightType.tip:
      default:
        // 💗 deeper pink/red for tips/default
        return const Color(0xFFC70039);
    }
  }

  IconData _iconForType(InsightType type) {
    switch (type) {
      case InsightType.alert:
      case InsightType.overspending:
        // 💡 better visual for negative/overspending
        return Icons.remove_circle_outline_rounded;
      case InsightType.trend:
        // 💡 timeline-style trend icon
        return Icons.timeline_rounded;
      case InsightType.tip:
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  String _labelForType(InsightType type) {
    switch (type) {
      case InsightType.overspending:
        return 'Overspending Alert';
      case InsightType.alert:
        return 'Critical Alert';
      case InsightType.trend:
        return 'Spending Trend';
      case InsightType.tip:
      default:
        return 'Daily Insight';
    }
  }

  @override
  Widget build(BuildContext context) {
    final InsightType type = insight.type;
    final Color accentColor = _colorForType(type);
    final String label = _labelForType(type);
    final IconData icon = _iconForType(type);

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
          // Left circular icon bubble
          Container(
            width: 40,
            height: 40,
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
            child: Center(child: Icon(icon, size: 22, color: accentColor)),
          ),
          const SizedBox(width: 12),

          // Right side: title + small label + description
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
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight.description,
                  style: const TextStyle(
                    color: BudgetaColors.textMuted,
                    fontSize: 12.5,
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
