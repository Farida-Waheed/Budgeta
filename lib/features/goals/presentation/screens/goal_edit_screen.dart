// lib/features/goals/presentation/screens/goal_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/widgets/modal_sheet.dart';
import '../../../../core/widgets/text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../state/goals_cubit.dart';

class GoalEditSheet extends StatefulWidget {
  final Goal goal;

  const GoalEditSheet({super.key, required this.goal});

  @override
  State<GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends State<GoalEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _currentCtrl;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.goal.name);
    _targetCtrl = TextEditingController(
      text: widget.goal.targetAmount.toStringAsFixed(2),
    );
    _currentCtrl = TextEditingController(
      text: widget.goal.currentAmount.toStringAsFixed(2),
    );
    _deadline = widget.goal.targetDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MagicModalSheet(
      title: 'Edit Goal ✏️',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          MagicTextField(label: 'Goal Name', controller: _nameCtrl),
          const SizedBox(height: 12),
          MagicTextField(
            label: 'Target Amount',
            controller: _targetCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          MagicTextField(
            label: 'Current Savings',
            controller: _currentCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),

          // Deadline picker
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Deadline',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: BudgetaColors.textMuted),
            ),
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: BudgetaColors.cardBorder.withValues(alpha: 0.7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onPressed: _pickDeadline,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              _deadline == null
                  ? 'Select a date (optional)'
                  : '${_deadline!.day.toString().padLeft(2, '0')}/'
                        '${_deadline!.month.toString().padLeft(2, '0')}/'
                        '${_deadline!.year}',
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Save changes', onPressed: _handleSave),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _handleSave() {
    final name = _nameCtrl.text.trim();
    final target = double.tryParse(_targetCtrl.text.trim()) ?? 0;
    final current = double.tryParse(_currentCtrl.text.trim()) ?? 0;

    if (name.isEmpty || target <= 0) {
      Navigator.of(context).pop();
      return;
    }

    final updated = widget.goal.copyWith(
      name: name,
      targetAmount: target,
      currentAmount: current,
      targetDate: _deadline,
    );

    context.read<GoalsCubit>().updateGoal(updated);
    Navigator.of(context).pop();
  }
}
