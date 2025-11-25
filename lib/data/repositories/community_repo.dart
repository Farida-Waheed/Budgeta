import 'package:uuid/uuid.dart';
import '../models/post.dart';

class CommunityRepository {
  final List<Post> _posts = [];
  final uuid = const Uuid();

  List<Post> getPosts() => _posts;

  void addPost({
    required String userId,
    required String content,
  }) {
    _posts.add(
      Post(
        id: uuid.v4(),
        userId: userId,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
  }

  void addComment({
    required String postId,
    required String userId,
    required String text,
  }) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];

    final updatedComments = List<Comment>.from(post.comments)
      ..add(Comment(
        userId: userId,
        text: text,
        createdAt: DateTime.now(),
      ));

    _posts[index] = Post(
      id: post.id,
      userId: post.userId,
      content: post.content,
      createdAt: post.createdAt,
      comments: updatedComments,
    );
  }
}
