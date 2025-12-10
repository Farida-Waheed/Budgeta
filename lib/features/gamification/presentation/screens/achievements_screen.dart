// lib/features/gamification/presentation/screens/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../state/gamification_cubit.dart';
import '../widgets/badge_chip.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GamificationCubit>();

    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Achievements',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<GamificationCubit, GamificationState>(
          bloc: cubit,
          builder: (context, state) {
            final unlocked = state.badges
                .where((b) => b.unlocked)
                .toList(growable: false);
            final locked = state.badges
                .where((b) => !b.unlocked)
                .toList(growable: false);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your sparkle wall ✨',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Collect badges as you join challenges, build streaks, and level up your money habits.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                if (unlocked.isNotEmpty) ...[
                  const Text(
                    'Unlocked',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: unlocked.map((b) => BadgeChip(badge: b)).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Coming soon',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(children: locked.map((b) => BadgeChip(badge: b)).toList()),
              ],
            );
          },
        ),
      ),
    );
  }
}
