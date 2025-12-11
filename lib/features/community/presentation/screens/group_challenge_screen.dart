// lib/features/community/presentation/screens/group_challenge_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/group_challenge.dart';
import '../../state/community_cubit.dart';

class GroupChallengeScreen extends StatelessWidget {
  const GroupChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: Column(
        children: [
          const _GroupChallengesHeader(),
          Expanded(
            child: SafeArea(
              top: false, // let the gradient header color the status bar area
              child: Container(
                decoration: const BoxDecoration(
                  color: BudgetaColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: BlocBuilder<CommunityCubit, CommunityState>(
                  builder: (context, state) {
                    final cubit = context.read<CommunityCubit>();
                    final challenges = state.groupChallenges;

                    if (challenges.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.groups_2_rounded,
                                size: 40,
                                color: BudgetaColors.deep,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No group challenges yet.\nCheck again soon for new quests ✨',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: BudgetaColors.deep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        final c = challenges[index];
                        return _ChallengeCard(
                          challenge: c,
                          onJoin: c.isJoined
                              ? null
                              : () => cubit.joinGroupChallenge(c.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient header similar to Challenges _Header
class _GroupChallengesHeader extends StatelessWidget {
  const _GroupChallengesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 12,
        top:
            44, // was 16 → now bigger, colors the top section like ForgotPassword
        bottom: 24,
      ),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Challenges 💪',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Save together, win together.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final GroupChallenge challenge;
  final VoidCallback? onJoin;

  const _ChallengeCard({super.key, required this.challenge, this.onJoin});

  @override
  Widget build(BuildContext context) {
    final double progress = (challenge.teamProgress ?? 0.0).clamp(0.0, 1.0);
    final int percent = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.pink.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + small badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  challenge.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: BudgetaColors.deep,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.groups_2_rounded,
                      size: 14,
                      color: BudgetaColors.deep,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.memberCount}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BudgetaColors.deep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            challenge.description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // progress bar styled like Challenges
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.pink.shade50,
              valueColor: const AlwaysStoppedAnimation<Color>(
                BudgetaColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percent% team progress',
                style: const TextStyle(
                  fontSize: 11,
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (challenge.myRank != null)
                Text(
                  'Your rank: #${challenge.myRank}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Join button – same color vibes as challenge dialog
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: challenge.isJoined
                    ? Colors.pink.shade100
                    : BudgetaColors.primary,
                disabledBackgroundColor: Colors.pink.shade100,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              onPressed: onJoin,
              child: Text(
                challenge.isJoined ? 'Already joined' : 'Join this group',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
