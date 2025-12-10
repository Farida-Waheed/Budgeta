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
      appBar: AppBar(
        backgroundColor: BudgetaColors.backgroundLight,
        elevation: 0,
        foregroundColor: BudgetaColors.deep,
        title: const Text('Group Challenges 💪'),
      ),
      body: SafeArea(
        child: BlocBuilder<CommunityCubit, CommunityState>(
          builder: (context, state) {
            final cubit = context.read<CommunityCubit>();
            final challenges = state.groupChallenges;

            if (challenges.isEmpty) {
              return const Center(
                child: Text(
                  'No group challenges yet.\nCheck again soon for new quests ✨',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challenge.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            challenge.description,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).round()}% team progress • ${challenge.memberCount} members',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          if (challenge.myRank != null)
            Text(
              'Your rank in this group: #${challenge.myRank}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: challenge.isJoined
                    ? Colors.grey.shade300
                    : BudgetaColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: onJoin,
              child: Text(
                challenge.isJoined ? 'Already joined' : 'Join this group',
                style: TextStyle(
                  color: challenge.isJoined
                      ? Colors.grey.shade700
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
