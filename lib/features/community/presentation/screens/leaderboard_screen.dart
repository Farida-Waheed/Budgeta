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
      appBar: AppBar(
        backgroundColor: BudgetaColors.backgroundLight,
        elevation: 0,
        foregroundColor: BudgetaColors.deep,
        title: const Text('Leaderboard ✨'),
      ),
      body: SafeArea(
        child: BlocBuilder<CommunityCubit, CommunityState>(
          builder: (context, state) {
            final entries = state.leaderboard;

            if (entries.isEmpty) {
              return const Center(
                child: Text(
                  'No leaderboard data yet.\nJoin challenges to climb the ranks! 🏆',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                final rank = e['rank'] as int;
                final userName = e['userName'] as String;
                final score = e['score'] as int;
                final isMe = userName.toLowerCase() == 'you';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? BudgetaColors.primary.withOpacity(0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMe ? BudgetaColors.primary : Colors.pink.shade50,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isMe
                            ? BudgetaColors.primary
                            : BudgetaColors.accentLight,
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
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isMe ? BudgetaColors.deep : Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        '$score pts',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
