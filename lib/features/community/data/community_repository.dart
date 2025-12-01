// lib/features/community/data/community_repository.dart
import '../../../core/models/post.dart';

abstract class CommunityRepository {
  // UC: View community feed
  Future<List<Post>> getFeed({required String userId});

  // UC: Create post
  Future<Post> createPost({
    required String userId,
    required String text,
    double? attachedProgress,
  });

  // UC: Like / unlike post
  Future<Post> toggleLike({
    required String userId,
    required String postId,
  });

  // UC: Comment on post
  Future<Post> addComment({
    required String userId,
    required String postId,
    required String text,
  });

  // UC: Leaderboard (simple: list of users with score)
  Future<List<Map<String, dynamic>>> getLeaderboard();
}
