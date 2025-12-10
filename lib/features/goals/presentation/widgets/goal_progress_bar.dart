import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class GoalProgressBar extends StatelessWidget {
  final double progress;

  const GoalProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 6,
        child: Stack(
          children: [
            // Soft pink track – matches Expense screen
            Container(color: BudgetaColors.accentLight.withValues(alpha: 0.35)),
            // Primary accent bar
            FractionallySizedBox(
              widthFactor: clamped,
              child: Container(color: BudgetaColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
