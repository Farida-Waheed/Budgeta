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
      body: SafeArea(
        child: Column(
          children: [
            const _AchievementsHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: BudgetaColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: BlocBuilder<GamificationCubit, GamificationState>(
                    bloc: cubit,
                    builder: (context, state) {
                      final unlocked = state.badges
                          .where((b) => b.unlocked)
                          .toList();
                      final locked = state.badges
                          .where((b) => !b.unlocked)
                          .toList();

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Page Title
                            const Text(
                              'Your sparkle wall ✨',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: BudgetaColors.deep,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Collect badges as you join challenges, build streaks, and level up your money habits.',
                              style: TextStyle(
                                fontSize: 12,
                                color: BudgetaColors.textMuted,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ------------------------------
                            //        UNLOCKED SECTION
                            // ------------------------------
                            if (unlocked.isNotEmpty) ...[
                              const Text(
                                'Unlocked',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: BudgetaColors.deep,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.pink.shade50,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: unlocked
                                      .map((b) => BadgeChip(badge: b))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // ------------------------------
                            //        LOCKED SECTION
                            // ------------------------------
                            const Text(
                              'Coming soon',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: BudgetaColors.deep,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.pink.shade50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: locked.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Text(
                                        'You’ve unlocked everything for now 🎉\nNew badges will appear as we add more quests.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.3,
                                          color: BudgetaColors.textMuted,
                                        ),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: locked
                                          .map((b) => BadgeChip(badge: b))
                                          .toList(),
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsHeader extends StatelessWidget {
  const _AchievementsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 20, top: 18, bottom: 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [BudgetaColors.primary, BudgetaColors.deep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achievements 💖',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your little money trophies, all in one place.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
