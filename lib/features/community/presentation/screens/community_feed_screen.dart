// lib/features/community/presentation/screens/community_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../shared/bottom_nav.dart';
import '../../../../core/models/group_challenge.dart';
import '../../data/community_repository_impl.dart';
import '../../state/community_cubit.dart';
import '../widgets/post_card.dart';
import 'create_post_screen.dart';
import 'leaderboard_screen.dart';
import 'group_challenge_screen.dart';
import 'post_details_screen.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityCubit(
        repository: InMemoryCommunityRepository(),
        userId: 'demo-user',
        userName: 'You',
      )..load(),
      child: const _CommunityView(),
    );
  }
}

class _CommunityView extends StatelessWidget {
  const _CommunityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 5),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: BudgetaColors.primary,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CommunityCubit>(),
                child: const CreatePostScreen(),
              ),
            ),
          );
        },
        label: const Text(
          'Share update 💬',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.edit, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocBuilder<CommunityCubit, CommunityState>(
          builder: (context, state) {
            final cubit = context.read<CommunityCubit>();

            return RefreshIndicator(
              onRefresh: () => cubit.refreshFeed(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      onTapLeaderboard: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: const LeaderboardScreen(),
                            ),
                          ),
                        );
                      },
                      onTapGroupChallenge: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: const GroupChallengeScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (state.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          const Text(
                            'Community Feed ✨',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'See how others are saving, winning, and learning.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          if (state.feed.isEmpty && !state.isLoading)
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
                                'No posts yet.\nShare your first win and inspire the community 💕',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ...state.feed.map(
                            (post) => PostCard(
                              post: post,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: cubit,
                                      child: PostDetailsScreen(postId: post.id),
                                    ),
                                  ),
                                );
                              },
                              onLike: () => cubit.toggleLike(post.id),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (state.groupChallenges.isNotEmpty)
                            _GroupChallengeTeaser(
                              challenge: state.groupChallenges.first,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: cubit,
                                      child: const GroupChallengeScreen(),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onTapLeaderboard,
    required this.onTapGroupChallenge,
  });

  final VoidCallback onTapLeaderboard;
  final VoidCallback onTapGroupChallenge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
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
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community 💕',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Together we sparkle brighter.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              IconButton(
                onPressed: onTapGroupChallenge,
                tooltip: 'Group Challenges',
                icon: const Icon(Icons.groups_2_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pills like the Figma (Top 10%, Level 5)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onTapLeaderboard,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Top 10%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Leaderboard',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.white24),
                Expanded(
                  child: InkWell(
                    onTap: onTapGroupChallenge,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Level 5',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Saver Status',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _GroupChallengeTeaser extends StatelessWidget {
  final GroupChallenge challenge;
  final VoidCallback onTap;

  const _GroupChallengeTeaser({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (challenge.teamProgress ?? 0.0).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [BudgetaColors.primary, BudgetaColors.deep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You're not alone! 🌟",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.name,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).round()}% team progress • ${challenge.memberCount} members',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
