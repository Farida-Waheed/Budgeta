// lib/features/community/data/community_repository.dart
import '../../../core/models/post.dart';
import '../../../core/models/group_challenge.dart';

abstract class CommunityRepository {
  // UC: View community feed
  Future<List<Post>> getFeed({required String userId});

  // UC: Create post
  Future<Post> createPost({
    required String userId,
    required String userName,
    required String text,
    double? attachedProgress,
  });

  // UC: Like / unlike post
  Future<Post> toggleLike({required String userId, required String postId});

  // UC: Comment on post
  Future<Post> addComment({
    required String userId,
    required String userName,
    required String postId,
    required String text,
  });

  // UC: View leaderboard
  /// Each map has: { 'rank': int, 'userName': String, 'score': int }
  Future<List<Map<String, dynamic>>> getLeaderboard();

  // UC: View & join group challenges
  Future<List<GroupChallenge>> getGroupChallenges({required String userId});

  Future<GroupChallenge> joinGroupChallenge({
    required String userId,
    required String challengeId,
  });

  // UC: Report content
  Future<void> reportContent({
    required String userId,
    required String postId,
    required String reason,
    String? details,
  });
}
