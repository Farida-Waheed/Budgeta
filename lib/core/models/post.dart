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
  final double? attachedProgress; // e.g. goal progress snapshot (0..1)
  final DateTime createdAt;
  final int likeCount;
  final bool isLikedByMe;
  final List<Comment> comments;

  const Post({
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

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? text,
    double? attachedProgress,
    DateTime? createdAt,
    int? likeCount,
    bool? isLikedByMe,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      text: text ?? this.text,
      attachedProgress: attachedProgress ?? this.attachedProgress,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      comments: comments ?? this.comments,
    );
  }
}
