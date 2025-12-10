// lib/features/goals/presentation/widgets/goal_cart.dart
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/widgets/card.dart';
import 'goal_prograss_bar.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final bool isFirst;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.goal,
    required this.isFirst,
    required this.onTap,
  });

  String _deadlineText() {
    if (goal.targetDate == null) return '—';
    final d = goal.targetDate!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress.isNaN ? 0.0 : goal.progress;
    final progressPercent = (progress * 100).round();
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(
      0,
      goal.targetAmount,
    );

    return GestureDetector(
      onTap: onTap,
      child: MagicCard(
        borderRadius: 22,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BudgetaColors.accentLight.withValues(alpha: 0.18),
                  ),
                  child: const Icon(
                    Icons.radio_button_unchecked,
                    size: 18,
                    color: BudgetaColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BudgetaColors.deep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '\$${goal.currentAmount.toStringAsFixed(2)}'
                  ' of \$${goal.targetAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BudgetaColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress bar & % label
            GoalProgressBar(progress: progress),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$progressPercent% complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BudgetaColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Remaining + Deadline row
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BudgetaColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${remaining.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BudgetaColors.deep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Deadline',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BudgetaColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _deadlineText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BudgetaColors.deep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (isFirst || progress >= 0.9)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: BudgetaColors.accentLight.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '✨ Almost there! Keep sparkling! ✨',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
