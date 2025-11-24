import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String content;

  const PostCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(content),
      ),
    );
  }
}
