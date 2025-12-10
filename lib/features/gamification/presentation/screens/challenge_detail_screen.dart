// lib/features/gamification/presentation/screens/challenge_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/challenge.dart';
import '../../../../app/theme.dart';
import '../../state/gamification_cubit.dart';

class ChallengeDetailsScreen extends StatelessWidget {
  const ChallengeDetailsScreen({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GamificationCubit>();
    final current = cubit.state.challenges.firstWhere(
      (c) => c.id == challenge.id,
      orElse: () => challenge,
    );

    final percent = (current.progress * 100).round();

    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Challenge details',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: BudgetaColors.deep,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              current.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            if (current.targetAmount != null)
              Text(
                'Target amount: ${current.targetAmount!.toStringAsFixed(0)} EGP',
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${current.durationDays} days',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: current.progress,
                minHeight: 10,
                backgroundColor: Colors.pink.shade50,
                valueColor: AlwaysStoppedAnimation<Color>(
                  BudgetaColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('$percent% complete', style: const TextStyle(fontSize: 12)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: BudgetaColors.primary,
                ),
                onPressed: current.isJoined
                    ? null
                    : () async {
                        await cubit.joinChallenge(current.id);
                        Navigator.of(context).pop();
                      },
                child: Text(
                  current.isJoined ? 'Already joined' : 'Join this challenge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (current.isJoined)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: BorderSide(color: BudgetaColors.primary),
                  ),
                  onPressed: () {
                    cubit.completeToday(current.id);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Mark today as completed'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
