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
          children: [
            for (final issue in issues) _IssueCard(issue: issue),
          ],
        ),
      ],
    );
  }
}

class _IssueCard extends StatelessWidget {
  final dash_repo.BudgetIssue issue;

  const _IssueCard({required this.issue});

  // Now handles both icon color and small label color
  Color _accentColor(String s) {
    switch (s.toLowerCase()) {
      case 'error':
        return const Color(0xFFEB3B5A); // warm red
      case 'warning':
        return const Color(0xFFF5A623); // warm orange
      default:
        return BudgetaColors.primary; // primary pink
    }
  }

  IconData _iconForSeverity(String s) {
    switch (s.toLowerCase()) {
      case 'error':
        return Icons.error_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _labelForSeverity(String s) {
    switch (s.toLowerCase()) {
      case 'error':
        return 'Critical Alert'; // Capitalized for consistency
      case 'warning':
        return 'Heads Up'; // Capitalized
      default:
        return 'Insight'; // Capitalized
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = _accentColor(issue.severity);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10), // Reduced margin slightly
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white, // Pure white background
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          // Light, subtle border color
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
          // Left circular icon bubble (Unified light theme gradient)
          Container(
            width: 40, // Standardized size to match Insights
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
            child: Icon(
              _iconForSeverity(issue.severity),
              size: 22,
              color: accent, // Icon color still reflects severity
            ),
          ),
          const SizedBox(width: 12),

          // Text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (Message) - Now bold/title-like
                Text(
                  issue.message,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),

                // Small label (Alert / Insight) - Now under the title, in accent color
                Text(
                  _labelForSeverity(issue.severity),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: accent, // Color still reflects severity
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