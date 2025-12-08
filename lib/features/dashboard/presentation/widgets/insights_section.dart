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

  // --- Helper Functions using InsightType ---

  Color _colorForType(InsightType type) {
    switch (type) {
      case InsightType.alert:
      case InsightType.overspending:
        return const Color(0xFFEB3B5A); // warm red
      case InsightType.trend:
        return const Color(0xFFF5A623); // warm orange
      case InsightType.tip:
      default:
        return BudgetaColors.primary; // primary pink
    }
  }

  IconData _iconForType(InsightType type) {
    switch (type) {
      case InsightType.alert:
      case InsightType.overspending:
        return Icons.error_outline_rounded;
      case InsightType.trend:
        return Icons.auto_graph_rounded; 
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
          // Left circular icon bubble (Standardized theme)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  BudgetaColors.accentLight.withValues(alpha: 0.7), // Standard light accent
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 22,
                color: accentColor, // Icon color matches the type
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Right side: title + small label + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (big & bold)
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

                // Tiny label under title (in accent color)
                Text(
                  label,
                  style: TextStyle(
                    color: accentColor, // Label color matches the type
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // Description (The main message)
                Text(
                  insight.description,
                  style: const TextStyle(
                    color: BudgetaColors.textMuted,
                    fontSize: 12.5, // Slightly larger for readability
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