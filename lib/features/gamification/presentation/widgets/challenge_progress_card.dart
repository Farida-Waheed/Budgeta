// lib/features/gamification/presentation/widgets/challenge_progress_card.dart
import 'package:flutter/material.dart';

import '../../../../core/models/challenge.dart';
import '../../../../app/theme.dart';

class ChallengeProgressCard extends StatelessWidget {
  const ChallengeProgressCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.onCompleteToday,
  });

  final Challenge challenge;
  final VoidCallback? onTap;
  final VoidCallback? onCompleteToday;

  @override
  Widget build(BuildContext context) {
    final percent = (challenge.progress * 100).round();
    final daysLeft = (challenge.durationDays - challenge.daysCompleted).clamp(
      0,
      challenge.durationDays,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.pink.shade50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: BudgetaColors.deep,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: challenge.progress,
                minHeight: 8,
                backgroundColor: Colors.pink.shade50,
                valueColor: AlwaysStoppedAnimation<Color>(
                  BudgetaColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percent% complete',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  daysLeft > 0
                      ? '$daysLeft days left'
                      : 'Challenge finished 🎉',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (challenge.isJoined &&
                    daysLeft > 0 &&
                    onCompleteToday != null)
                  TextButton(
                    onPressed: onCompleteToday,
                    child: const Text('Mark today done'),
                  ),
                if (!challenge.isJoined && onTap != null)
                  TextButton(
                    onPressed: onTap,
                    child: const Text('View & Join'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
