// lib/features/community/presentation/screens/post_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../state/community_cubit.dart';
import '../widgets/post_card.dart';
import '../widgets/comment_list.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final cubit = context.read<CommunityCubit>();
    await cubit.addComment(widget.postId, text);
    _commentController.clear();
  }

  Future<void> _reportPost() async {
    final cubit = context.read<CommunityCubit>();
    String? selectedReason;
    final detailsController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const Text(
                    'Report Content',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<String>(
                    title: const Text('Spam or misleading'),
                    value: 'Spam',
                    groupValue: selectedReason,
                    onChanged: (v) => setModalState(() => selectedReason = v),
                  ),
                  RadioListTile<String>(
                    title: const Text('Hate / harassment'),
                    value: 'Hate / Harassment',
                    groupValue: selectedReason,
                    onChanged: (v) => setModalState(() => selectedReason = v),
                  ),
                  RadioListTile<String>(
                    title: const Text('Inappropriate or unsafe'),
                    value: 'Inappropriate',
                    groupValue: selectedReason,
                    onChanged: (v) => setModalState(() => selectedReason = v),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Additional details (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BudgetaColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: selectedReason == null
                          ? null
                          : () {
                              Navigator.of(context).pop(true);
                            },
                      child: const Text(
                        'Submit report',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result == true && selectedReason != null) {
      await cubit.reportContent(
        postId: widget.postId,
        reason: selectedReason!,
        details: detailsController.text.trim().isEmpty
            ? null
            : detailsController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you. Your report was submitted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: BudgetaColors.backgroundLight,
        elevation: 0,
        foregroundColor: BudgetaColors.deep,
        title: const Text('Post'),
        actions: [
          IconButton(
            onPressed: _reportPost,
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Report content',
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<CommunityCubit, CommunityState>(
          builder: (context, state) {
            final cubit = context.read<CommunityCubit>();
            final post = cubit.findPostById(widget.postId);

            if (post == null) {
              return const Center(
                child: Text('This post is no longer available.'),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PostCard(
                          post: post,
                          onLike: () => cubit.toggleLike(post.id),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Comments 💬',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CommentList(comments: post.comments),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Write a comment…',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _submitComment,
                          icon: const Icon(Icons.send_rounded),
                          color: BudgetaColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
