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
      appBar: AppBar(
        backgroundColor: BudgetaColors.backgroundLight,
        elevation: 0,
        foregroundColor: BudgetaColors.deep,
        title: const Text('Share a Win 💕'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _textController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'What would you like to share?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Write something first ✨';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Attach goal progress (optional)',
                    style: TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  if (_attachedProgress != null)
                    Text(
                      '${(_attachedProgress! * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              Slider(
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BudgetaColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Post to Community ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
