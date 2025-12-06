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
          'Budget health 🩺',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
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

  Color _colorForSeverity(String s) {
    switch (s.toLowerCase()) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return BudgetaColors.deep;
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

  @override
  Widget build(BuildContext context) {
    final color = _colorForSeverity(issue.severity);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconForSeverity(issue.severity),
              size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              issue.message,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
