// lib/core/models/post.dart
class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });
}

class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String text;
  final double? attachedProgress; // e.g. goal progress snapshot
  final DateTime createdAt;
  final int likeCount;
  final bool isLikedByMe;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.text,
    this.attachedProgress,
    required this.createdAt,
    this.likeCount = 0,
    this.isLikedByMe = false,
    this.comments = const [],
  });
}
