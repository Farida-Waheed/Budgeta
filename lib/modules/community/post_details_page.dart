import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../../widgets/app_textfield.dart';
//import '../../widgets/app_button.dart';
import 'community_controller.dart';
import '../../data/models/post.dart';

class PostDetailsPage extends StatefulWidget {
  final Post post;

  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CommunityController>(context);

    final post = widget.post;
    final comments = controller.posts
        .firstWhere((p) => p.id == post.id)
        .comments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post", style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main post
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Comments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Comments list
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (_, index) {
                  final c = comments[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(c.text),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Add comment box
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: "Write a comment...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.red),
                  onPressed: () {
                    if (commentController.text.isEmpty) return;

                    controller.addComment(
                      post.id,
                      "user1",
                      commentController.text,
                    );

                    commentController.clear();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
