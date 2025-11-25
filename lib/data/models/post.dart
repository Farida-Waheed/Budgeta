class Post {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.comments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "content": content,
      "createdAt": createdAt.toIso8601String(),
      "comments": comments.map((c) => c.toMap()).toList(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map["id"],
      userId: map["userId"],
      content: map["content"],
      createdAt: DateTime.parse(map["createdAt"]),
      comments: (map["comments"] as List<dynamic>)
          .map((e) => Comment.fromMap(e))
          .toList(),
    );
  }
}

class Comment {
  final String userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "text": text,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map["userId"],
      text: map["text"],
      createdAt: DateTime.parse(map["createdAt"]),
    );
  }
}
