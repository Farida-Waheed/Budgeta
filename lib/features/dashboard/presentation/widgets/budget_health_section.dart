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

  Color _accentColor(String s) {
    switch (s.toLowerCase()) {
      case 'error':
        return const Color(0xFFEB3B5A); // warm red
      case 'warning':
        return const Color(0xFFF5A623); // warm orange
      default:
        return BudgetaColors.primary;
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
        return 'Critical alert';
      case 'warning':
        return 'Heads up';
      default:
        return 'Insight';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(issue.severity);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withOpacity(0.5),
          width: 1.3,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            accent.withOpacity(0.06),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // circular icon bubble
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  accent.withOpacity(0.20),
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

          // text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelForSeverity(issue.severity),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  issue.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: BudgetaColors.deep,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
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
