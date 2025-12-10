// lib/features/gamification/presentation/widgets/badge_chip.dart
import 'package:flutter/material.dart' hide Badge;

import '../../../../core/models/badge.dart';
import '../../../../app/theme.dart';

class BadgeChip extends StatelessWidget {
  const BadgeChip({super.key, required this.badge});

  final Badge badge;

  @override
  Widget build(BuildContext context) {
    final bool locked = !badge.unlocked;

    return Opacity(
      opacity: locked ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: locked ? Colors.grey.shade300 : BudgetaColors.accentLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(badge.iconName, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: locked ? Colors.grey : BudgetaColors.deep,
                  ),
                ),
                Text(
                  badge.description,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
