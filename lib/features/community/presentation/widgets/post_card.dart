// lib/features/community/presentation/widgets/post_card.dart
import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onCommentTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = post.createdAt;
    final dateString =
        '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.pink.shade50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + name + date
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: BudgetaColors.accentLight,
                  child: Text(
                    post.userName.isNotEmpty
                        ? post.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: BudgetaColors.deep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        dateString,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.text,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
            if (post.attachedProgress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: post.attachedProgress!.clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: Colors.pink.shade50,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    BudgetaColors.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  onTap: onLike,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          post.isLikedByMe
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: post.isLikedByMe
                              ? BudgetaColors.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likeCount} likes',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: onCommentTap ?? onTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.comments.length} comments',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
