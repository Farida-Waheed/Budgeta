// lib/features/community/presentation/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../state/community_cubit.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: Column(
        children: [
          const _LeaderboardHeader(), // now fully extended gradient
          Expanded(
            child: SafeArea(
              top: false, // keep gradient covering the status bar
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
                    final entries = state.leaderboard;

                    if (entries.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 42,
                                color: BudgetaColors.deep,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No leaderboard data yet.\nJoin challenges to climb the ranks! 🏆',
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
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final e = entries[index];
                        final rank = e['rank'] as int;
                        final userName = e['userName'] as String;
                        final score = e['score'] as int;
                        final isMe = userName.toLowerCase() == 'you';

                        return _LeaderboardTile(
                          rank: rank,
                          userName: userName,
                          score: score,
                          isMe: isMe,
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

/// BIGGER gradient header (matches ForgotPassword / Coach style)
class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 12,
        top: 44, // increased from 16 → now colors the whole top section
        bottom: 28,
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
                  'Leaderboard ✨',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'See who’s shining the brightest this week.',
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

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String userName;
  final int score;
  final bool isMe;

  const _LeaderboardTile({
    required this.rank,
    required this.userName,
    required this.score,
    required this.isMe,
  });

  Color _medalColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return BudgetaColors.accentLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final medalColor = _medalColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isMe ? Colors.pink.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isMe ? BudgetaColors.primary : Colors.pink.shade50,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isMe ? BudgetaColors.primary : medalColor,
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: BudgetaColors.deep,
                  ),
                ),
                if (isMe)
                  const Text(
                    'That’s you 💖',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$score pts',
              style: const TextStyle(
                fontSize: 12,
                color: BudgetaColors.deep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
