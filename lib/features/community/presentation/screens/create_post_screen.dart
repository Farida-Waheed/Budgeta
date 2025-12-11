// lib/features/community/presentation/screens/create_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../state/community_cubit.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  double? _attachedProgress;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final text = _textController.text;
    final cubit = context.read<CommunityCubit>();

    await cubit.createPost(text, attachedProgress: _attachedProgress);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: Column(
        children: [
          const _CreatePostHeader(),
          Expanded(
            child: SafeArea(
              top: false, // let header gradient color the status bar area
              child: Container(
                decoration: const BoxDecoration(
                  color: BudgetaColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main white card (like challenge dialog style)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Share a win with the community 💕',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: BudgetaColors.deep,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'It can be tiny or huge – every step counts ✨',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: BudgetaColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Post text field
                              TextFormField(
                                controller: _textController,
                                maxLines: 6,
                                decoration: InputDecoration(
                                  hintText:
                                      'What did you achieve today? 🎉\n\nExample: “Paid off my credit card!”',
                                  alignLabelWithHint: true,
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.pink.shade100,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.pink.shade100,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: BudgetaColors.primary,
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Write something first ✨';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Progress attach section
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50.withValues(
                                    alpha: 0.4,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome,
                                          size: 18,
                                          color: BudgetaColors.deep,
                                        ),
                                        const SizedBox(width: 8),
                                        const Expanded(
                                          child: Text(
                                            'Attach goal progress (optional)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: BudgetaColors.deep,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (_attachedProgress != null)
                                          Text(
                                            '${(_attachedProgress! * 100).round()}%',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: BudgetaColors.deep,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Let others see how far you’ve come.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700.withOpacity(
                                          0.9,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Slider with themed colors
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: BudgetaColors.primary,
                                        inactiveTrackColor:
                                            Colors.pink.shade100,
                                        thumbColor: BudgetaColors.primary,
                                        overlayColor: BudgetaColors.primary
                                            .withValues(alpha: 0.15),
                                      ),
                                      child: Slider(
                                        value: (_attachedProgress ?? 0.0),
                                        min: 0,
                                        max: 1,
                                        divisions: 10,
                                        label: _attachedProgress == null
                                            ? '0%'
                                            : '${((_attachedProgress ?? 0) * 100).round()}%',
                                        onChanged: (value) {
                                          setState(() {
                                            _attachedProgress = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),

                              // Post button with gradient (like challenge dialog)
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        BudgetaColors.primary,
                                        BudgetaColors.deep,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.20,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextButton(
                                    onPressed: _submit,
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: const Text(
                                      'Post to Community ✨',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header styled like the Challenges header
class _CreatePostHeader extends StatelessWidget {
  const _CreatePostHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 12,
        top: 44, // was 16 — now bigger & coloring the top section
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share a Win 💕',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Celebrate your progress with the community.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}
