// lib/features/community/data/community_repository_impl.dart
import 'dart:math';

import '../../../core/models/post.dart';
import '../../../core/models/group_challenge.dart';
import 'community_repository.dart';

class InMemoryCommunityRepository implements CommunityRepository {
  final _random = Random();

  // Pretend DB in memory
  final List<Post> _posts = [];
  final List<GroupChallenge> _groupChallenges = [
    const GroupChallenge(
      id: 'coffee',
      name: 'Coffee Cutback Crew ☕️',
      description: 'Save together by skipping pricy coffee 3x a week.',
      memberCount: 128,
      teamProgress: 0.64,
    ),
    const GroupChallenge(
      id: 'no-spend',
      name: 'No-Spend Weekend ✨',
      description: 'Spend zero on non-essentials this weekend.',
      memberCount: 86,
      teamProgress: 0.42,
    ),
  ];

  InMemoryCommunityRepository() {
    // Seed some demo posts only once
    if (_posts.isEmpty) {
      final now = DateTime.now();
      _posts.addAll([
        Post(
          id: '1',
          userId: 'emma',
          userName: 'Emma Rose',
          text:
              'Just hit my first savings goal! 🎉✨ Feeling so empowered! Who else is crushing their financial dreams?',
          createdAt: now.subtract(const Duration(hours: 2)),
          likeCount: 24,
          isLikedByMe: false,
          comments: [
            Comment(
              id: 'c1',
              userId: 'demo-user',
              userName: 'You',
              text: 'Yaaay congrats Emma, so proud of you! 💖',
              createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
            ),
          ],
        ),
        Post(
          id: '2',
          userId: 'sophie',
          userName: 'Sophie Chen',
          text:
              'Coffee challenge update: Saved 300 EGP this week by brewing at home! ☕️💸 Small wins add up!',
          createdAt: now.subtract(const Duration(hours: 3)),
          likeCount: 18,
          isLikedByMe: true,
          comments: const [],
        ),
        Post(
          id: '3',
          userId: 'mia',
          userName: 'Mia Taylor',
          text: 'Anyone else doing the Budget Boss Challenge? We got this! 💪✨',
          createdAt: now.subtract(const Duration(days: 1)),
          likeCount: 31,
          isLikedByMe: false,
          comments: const [],
        ),
      ]);
    }
  }

  @override
  Future<List<Post>> getFeed({required String userId}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    // newest first
    final sorted = [..._posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<Post> createPost({
    required String userId,
    required String userName,
    required String text,
    double? attachedProgress,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final post = Post(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      userName: userName,
      text: text.trim(),
      attachedProgress: attachedProgress,
      createdAt: DateTime.now(),
      likeCount: 0,
      isLikedByMe: false,
      comments: const [],
    );
    _posts.add(post);
    return post;
  }

  @override
  Future<Post> toggleLike({
    required String userId,
    required String postId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) throw Exception('Post not found');

    final current = _posts[idx];
    final nowLiked = !current.isLikedByMe;
    final updated = current.copyWith(
      isLikedByMe: nowLiked,
      likeCount: max(0, current.likeCount + (nowLiked ? 1 : -1)),
    );
    _posts[idx] = updated;
    return updated;
  }

  @override
  Future<Post> addComment({
    required String userId,
    required String userName,
    required String postId,
    required String text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) throw Exception('Post not found');

    final current = _posts[idx];
    final newComment = Comment(
      id: 'c_${DateTime.now().microsecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    final updated = current.copyWith(
      comments: [...current.comments, newComment],
    );
    _posts[idx] = updated;
    return updated;
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      {
        'rank': 1,
        'userName': 'You',
        'score': 150, // e.g. challenge points
      },
      {'rank': 2, 'userName': 'Emma Rose', 'score': 142},
      {'rank': 3, 'userName': 'Sophie Chen', 'score': 129},
      {'rank': 4, 'userName': 'Mia Taylor', 'score': 115},
    ];
  }

  @override
  Future<List<GroupChallenge>> getGroupChallenges({
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List<GroupChallenge>.unmodifiable(_groupChallenges);
  }

  @override
  Future<GroupChallenge> joinGroupChallenge({
    required String userId,
    required String challengeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _groupChallenges.indexWhere((c) => c.id == challengeId);
    if (idx == -1) throw Exception('Challenge not found');

    final current = _groupChallenges[idx];
    final updated = current.copyWith(
      isJoined: true,
      memberCount: current.memberCount + 1,
      myRank: _random.nextInt(20) + 1,
    );
    _groupChallenges[idx] = updated;
    return updated;
  }

  @override
  Future<void> reportContent({
    required String userId,
    required String postId,
    required String reason,
    String? details,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    // In a real implementation, we'd persist the report.
    // Here we just "pretend" it was sent successfully.
    return;
  }
}
