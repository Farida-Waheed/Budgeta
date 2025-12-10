// lib/features/gamification/presentation/screens/challenges_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../shared/bottom_nav.dart';
import '../../data/gamification_repository_impl.dart';
import '../../state/gamification_cubit.dart';
import '../../../../core/models/challenge.dart';
import '../widgets/challenge_progress_card.dart';
import 'achievements_screen.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GamificationCubit(
        InMemoryGamificationRepository(),
        userId: 'demo-user', // plug real user id later
      )..load(),
      child: const _ChallengesView(),
    );
  }
}

class _ChallengesView extends StatelessWidget {
  const _ChallengesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 4),
      body: SafeArea(
        child: BlocBuilder<GamificationCubit, GamificationState>(
          builder: (context, state) {
            final cubit = context.read<GamificationCubit>();

            final activeChallenges = state.challenges
                .where((c) => c.isJoined)
                .toList();
            final discoverChallenges = state.challenges
                .where((c) => !c.isJoined)
                .toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    weeklyFeedback: state.weeklyFeedback,
                    onTapAchievements: () {
                      final cubit = context.read<GamificationCubit>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const AchievementsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (state.errorMessage != null &&
                            state.errorMessage!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (activeChallenges.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Your Active Quests ✨',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Keep the streak alive! Update today’s progress.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ...activeChallenges.map(
                            (ch) => ChallengeProgressCard(
                              challenge: ch,
                              onTap: () => _showChallengeDialog(context, ch),
                              onCompleteToday: () => cubit.completeToday(ch.id),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const Text(
                          'Discover New Challenges 💪',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pick one that matches your mood and money goals.',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        if (discoverChallenges.isEmpty &&
                            activeChallenges.isEmpty &&
                            !state.isLoading)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              'No challenges available right now.\nCheck back soon for fresh quests ✨',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ...discoverChallenges.map(
                          (ch) => ChallengeProgressCard(
                            challenge: ch,
                            onTap: () => _showChallengeDialog(context, ch),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// --------- Fancy flip + zoom dialog for challenge details ---------
void _showChallengeDialog(BuildContext context, Challenge challenge) {
  final cubit = context.read<GamificationCubit>();
  final current = cubit.state.challenges.firstWhere(
    (c) => c.id == challenge.id,
    orElse: () => challenge,
  );

  final percent = (current.progress * 100).round();
  final daysLeft = (current.durationDays - current.daysCompleted).clamp(
    0,
    current.durationDays,
  );

  showGeneralDialog(
    context: context,
    barrierLabel: 'challenge-details',
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.25),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (dialogContext, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final flip = Tween<double>(begin: pi / 2, end: 0).animate(curved);
      final scale = Tween<double>(begin: 0.9, end: 1).animate(curved);

      return Opacity(
        opacity: curved.value,
        child: Transform.scale(
          scale: scale.value,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(flip.value),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _ChallengeDialogCard(
                  challenge: current,
                  percent: percent,
                  daysLeft: daysLeft,
                  onJoin: current.isJoined
                      ? null
                      : () async {
                          await cubit.joinChallenge(current.id);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                  onCompleteToday: current.isJoined && daysLeft > 0
                      ? () async {
                          await cubit.completeToday(current.id);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        }
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ChallengeDialogCard extends StatelessWidget {
  const _ChallengeDialogCard({
    required this.challenge,
    required this.percent,
    required this.daysLeft,
    this.onJoin,
    this.onCompleteToday,
  });

  final Challenge challenge;
  final int percent;
  final int daysLeft;
  final VoidCallback? onJoin;
  final VoidCallback? onCompleteToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.pink.shade50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + subtitle
            Text(
              challenge.name,
              style: theme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: BudgetaColors.deep,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              challenge.description,
              style: theme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            if (challenge.targetAmount != null)
              Text(
                'Target: ${challenge.targetAmount!.toStringAsFixed(0)} EGP',
                style: theme.bodySmall?.copyWith(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (challenge.targetAmount != null) const SizedBox(height: 4),

            Text(
              'Duration: ${challenge.durationDays} days',
              style: theme.bodySmall?.copyWith(
                color: BudgetaColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Progress bar (same vibe as list card)
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: challenge.progress,
                minHeight: 8,
                backgroundColor: Colors.pink.shade50,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  BudgetaColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Progress labels (fixed yellow → deep color)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percent% complete',
                  style: const TextStyle(
                    fontSize: 12,
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  daysLeft > 0
                      ? '$daysLeft days left'
                      : 'Challenge finished 🎉',
                  style: const TextStyle(
                    fontSize: 12,
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Buttons – same color vibes as challenge card / app theme
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetaColors.primary,
                  disabledBackgroundColor: Colors.pink.shade100,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  challenge.isJoined ? 'Already joined' : 'Join this challenge',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (onCompleteToday != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCompleteToday,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: BudgetaColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Mark today as completed',
                    style: TextStyle(
                      color: BudgetaColors.deep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w600,
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

class _Header extends StatelessWidget {
  const _Header({
    required this.weeklyFeedback,
    required this.onTapAchievements,
  });

  final String weeklyFeedback;
  final VoidCallback onTapAchievements;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [BudgetaColors.primary, BudgetaColors.deep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row like your Figma (title + profile/achievements icon)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Challenges 💖',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Turn good habits into little wins.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              IconButton(
                onPressed: onTapAchievements,
                icon: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                ),
                tooltip: 'View Achievements',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weekly feedback card – similar style to bottom pink cards in designs
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    weeklyFeedback.isEmpty
                        ? 'We’ll craft your weekly feedback once you join a challenge 🌟'
                        : weeklyFeedback,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
