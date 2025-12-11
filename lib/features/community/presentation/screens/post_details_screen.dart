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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: BudgetaColors.backgroundLight,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: BudgetaColors.accentLight.withValues(
                            alpha: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const Text(
                        'Report Content',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: BudgetaColors.deep,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        activeColor: BudgetaColors.primary,
                        title: const Text('Spam or misleading'),
                        value: 'Spam',
                        groupValue: selectedReason,
                        onChanged: (v) =>
                            setModalState(() => selectedReason = v),
                      ),
                      RadioListTile<String>(
                        activeColor: BudgetaColors.primary,
                        title: const Text('Hate / harassment'),
                        value: 'Hate / Harassment',
                        groupValue: selectedReason,
                        onChanged: (v) =>
                            setModalState(() => selectedReason = v),
                      ),
                      RadioListTile<String>(
                        activeColor: BudgetaColors.primary,
                        title: const Text('Inappropriate or unsafe'),
                        value: 'Inappropriate',
                        groupValue: selectedReason,
                        onChanged: (v) =>
                            setModalState(() => selectedReason = v),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: detailsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Additional details (optional)',
                          labelStyle: const TextStyle(
                            color: BudgetaColors.textMuted,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: BudgetaColors.accentLight.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9A0E3A), Color(0xFFFF4F8B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
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
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
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
      body: Column(
        children: [
          _PostHeader(onReportTap: _reportPost),
          Expanded(
            child: SafeArea(
              top: false, // let gradient go behind status bar
              child: Container(
                decoration: const BoxDecoration(
                  color: BudgetaColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: BlocBuilder<CommunityCubit, CommunityState>(
                  builder: (context, state) {
                    final cubit = context.read<CommunityCubit>();
                    final post = cubit.findPostById(widget.postId);

                    if (post == null) {
                      return const Center(
                        child: Text(
                          'This post is no longer available.',
                          style: TextStyle(color: BudgetaColors.deep),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PostCard(
                                  post: post,
                                  onLike: () => cubit.toggleLike(post.id),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Comments 💬',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: BudgetaColors.deep,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.03,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    12,
                                    4,
                                  ),
                                  child: CommentList(comments: post.comments),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          decoration: BoxDecoration(
                            color: BudgetaColors.backgroundLight,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -4),
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
                                    decoration: InputDecoration(
                                      hintText: 'Write a comment…',
                                      hintStyle: const TextStyle(
                                        fontSize: 13,
                                        color: BudgetaColors.textMuted,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(22),
                                        borderSide: BorderSide(
                                          color: BudgetaColors.accentLight
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 12,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _submitComment,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF4F8B),
                                          Color(0xFF9A0E3A),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient header similar to Challenges _Header
class _PostHeader extends StatelessWidget {
  final VoidCallback onReportTap;

  const _PostHeader({required this.onReportTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 12,
        top: 44, // was 16 → now bigger, gradient covers status bar area
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [BudgetaColors.primary, BudgetaColors.deep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Post 💕',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Celebrate wins & support others.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onReportTap,
            icon: const Icon(Icons.flag_outlined, color: Colors.white),
            tooltip: 'Report content',
          ),
        ],
      ),
    );
  }
}
