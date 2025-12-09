import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../data/dashboard_repository.dart' as dash_repo;

class BudgetHealthSection extends StatelessWidget {
  final List<dash_repo.BudgetIssue> issues;

  const BudgetHealthSection({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Checkup 🩺',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [for (final issue in issues) _IssueCard(issue: issue)],
        ),
      ],
    );
  }
}

class _IssueCard extends StatelessWidget {
  final dash_repo.BudgetIssue issue;

  const _IssueCard({required this.issue});

  // Handles icon color and label color
  Color _accentColor(String s) {
    switch (s.toLowerCase()) {
      case 'error':
        return const Color(0xFFEB3B5A); // warm red
      case 'warning':
        // 💗 Updated warning color to pink-friendly hue
        return const Color(0xFFF75586);
      default:
        // 💗 Deeper red/pink for default/info
        return const Color(0xFFC70039);
    }
  }

  IconData _iconForSeverity(String s) {
    switch (s.toLowerCase()) {
      case 'error':
        // 💡 More modern alert icon
        return Icons.notification_important_rounded;
      case 'warning':
        // 💡 Softer "heads up" icon
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _labelForSeverity(String s) {
    switch (s.toLowerCase()) {
      case 'error':
        return 'Critical Alert';
      case 'warning':
        return 'Heads Up';
      default:
        return 'Insight';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = _accentColor(issue.severity);

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
            child: Icon(
              _iconForSeverity(issue.severity),
              size: 22,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),

          // Text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.message,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _labelForSeverity(issue.severity),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: accent,
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
