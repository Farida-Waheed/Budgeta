import 'package:flutter/material.dart';
import '../../data/repositories/community_repo.dart';
import '../../data/models/post.dart';

class CommunityController extends ChangeNotifier {
  final CommunityRepository repo;

  CommunityController(this.repo);

  List<Post> get posts => repo.getPosts();

  void addPost(String userId, String content) {
    repo.addPost(userId: userId, content: content);
    notifyListeners();
  }

  void addComment(String postId, String userId, String text) {
    repo.addComment(postId: postId, userId: userId, text: text);
    notifyListeners();
  }
}
