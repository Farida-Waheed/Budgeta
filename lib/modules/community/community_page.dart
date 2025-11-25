import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/colors.dart';
//import '../../widgets/app_textfield.dart';
import 'community_controller.dart';
import '../../data/models/post.dart';
import 'post_details_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CommunityController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Community", style: TextStyle(fontWeight: FontWeight.bold)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Add new post box
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: postController,
                    decoration: const InputDecoration(
                      hintText: "Share something...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.red),
                  onPressed: () {
                    if (postController.text.isEmpty) return;

                    controller.addPost("user1", postController.text);
                    postController.clear();
                  },
                )
              ],
            ),

            const SizedBox(height: 20),

            // Posts list
            Expanded(
              child: ListView.builder(
                itemCount: controller.posts.length,
                itemBuilder: (_, index) {
                  final post = controller.posts[index];
                  return _postCard(context, post);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(BuildContext context, Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailsPage(post: post)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "${post.comments.length} comments",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
