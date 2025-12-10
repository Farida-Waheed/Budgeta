// lib/features/goals/presentation/screens/goal_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/widgets/modal_sheet.dart';
import '../../../../core/widgets/text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../state/goals_cubit.dart';
import '../../../goals/presentation/widgets/goal_progress_bar.dart';

class GoalDetailsSheet extends StatefulWidget {
  final String goalId;
  final VoidCallback? onEdit;

  const GoalDetailsSheet({super.key, required this.goalId, this.onEdit});

  @override
  State<GoalDetailsSheet> createState() => _GoalDetailsSheetState();
}

class _GoalDetailsSheetState extends State<GoalDetailsSheet> {
  final _contributionCtrl = TextEditingController();

  @override
  void dispose() {
    _contributionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, state) {
        if (state is! GoalsLoaded) {
          return const MagicModalSheet(
            title: 'Goal Details',
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final goals = state.goals;
        final goal = goals.firstWhere(
          (g) => g.id == widget.goalId,
          orElse: () => goals.first,
        );

        final remaining = (goal.targetAmount - goal.currentAmount).clamp(
          0,
          goal.targetAmount,
        );
        final percent = (goal.progress * 100).clamp(0, 100).round();

        return MagicModalSheet(
          title: goal.name,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Progress
              Text(
                '\$${goal.currentAmount.toStringAsFixed(2)} of '
                '\$${goal.targetAmount.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: BudgetaColors.textMuted),
              ),
              const SizedBox(height: 6),
              GoalProgressBar(progress: goal.progress),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining: \$${remaining.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BudgetaColors.deep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$percent% complete',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BudgetaColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Projection section
              Text(
                'AI Projection',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              if (goal.projection == null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ask Budgeta’s AI to estimate when you’ll reach this goal '
                        'and how much to save each month.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BudgetaColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        context.read<GoalsCubit>().requestProjection(goal.id);
                      },
                      child: const Text('Ask AI ✨'),
                    ),
                  ],
                )
              else
                _ProjectionSummary(goal: goal),

              const SizedBox(height: 18),

              // Add contribution
              MagicTextField(
                label: 'Add Contribution',
                controller: _contributionCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Add to Goal',
                onPressed: () {
                  final amount =
                      double.tryParse(_contributionCtrl.text.trim()) ?? 0;
                  if (amount <= 0) return;
                  context.read<GoalsCubit>().addContribution(
                    goalId: goal.id,
                    amount: amount,
                  );
                  _contributionCtrl.clear();
                },
              ),

              const SizedBox(height: 12),

              // Edit button
              TextButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit goal details'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectionSummary extends StatelessWidget {
  final Goal goal;

  const _ProjectionSummary({required this.goal});

  String _dateText(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final proj = goal.projection!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BudgetaColors.accentLight.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated completion: ${_dateText(proj.estimatedCompletionDate)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BudgetaColors.deep,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Suggested monthly saving: '
            '\$${proj.suggestedMonthlySaving.toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BudgetaColors.deep),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your current progress and spending pattern.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BudgetaColors.textMuted),
          ),
        ],
      ),
    );
  }
}
