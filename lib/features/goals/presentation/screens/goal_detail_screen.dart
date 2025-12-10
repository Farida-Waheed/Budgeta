// lib/features/goals/presentation/screens/goal_detail_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/widgets/modal_sheet.dart';
import '../../../../core/widgets/text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../state/goals_cubit.dart';
import '../widgets/goal_progress_bar.dart';
import 'goal_edit_screen.dart';

class GoalDetailsSheet extends StatefulWidget {
  final String goalId;

  const GoalDetailsSheet({super.key, required this.goalId});

  @override
  State<GoalDetailsSheet> createState() => _GoalDetailsSheetState();
}

class _GoalDetailsSheetState extends State<GoalDetailsSheet> {
  final _contributionCtrl = TextEditingController();
  bool _showBack = false;

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
            title: 'Goal',
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final goals = state.goals;
        final Goal goal = goals.firstWhere(
          (g) => g.id == widget.goalId,
          orElse: () => goals.first,
        );

        final remaining = (goal.targetAmount - goal.currentAmount).clamp(
          0,
          goal.targetAmount,
        );
        final progress = goal.progress.isNaN ? 0.0 : goal.progress;
        final percent = (progress * 100).clamp(0, 100).round();

        return MagicModalSheet(
          title: goal.name,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              // --------- FLIPPING CARD ---------
              GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    final rotate = Tween(
                      begin: math.pi,
                      end: 0.0,
                    ).animate(animation);

                    return AnimatedBuilder(
                      animation: rotate,
                      child: child,
                      builder: (context, child) {
                        return Transform(
                          transform: Matrix4.rotationY(rotate.value),
                          alignment: Alignment.center,
                          child: child,
                        );
                      },
                    );
                  },
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
                  child: _showBack
                      ? _buildBackCard(context, goal, remaining, percent)
                      : _buildFrontCard(context, goal, remaining, percent),
                ),
              ),

              const SizedBox(height: 14),
              Text(
                _showBack
                    ? 'Tap the card to flip to the front.'
                    : 'Tap the card to see more details.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BudgetaColors.textMuted,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 20),

              // --------- ACTIONS UNDER CARD ---------
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Ask AI
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<GoalsCubit>().requestProjection(goal.id);
                      },
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('Ask AI ✨'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BudgetaColors.deep,
                        side: BorderSide(
                          color: BudgetaColors.primary.withValues(alpha: 0.7),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openEditGoal(context, goal),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit goal'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BudgetaColors.deep,
                        side: BorderSide(
                          color: BudgetaColors.accentLight.withValues(
                            alpha: 0.9,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Add contribution
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add contribution',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BudgetaColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              MagicTextField(
                label: 'Amount',
                controller: _contributionCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: 'Add to goal',
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

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ---------------- CARD SIDES ----------------

  Widget _buildFrontCard(
    BuildContext context,
    Goal goal,
    num remaining,
    int percent,
  ) {
    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: BudgetaColors.accentLight.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: BudgetaColors.deep,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${goal.currentAmount.toStringAsFixed(2)} of '
            '\$${goal.targetAmount.toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 14),
          GoalProgressBar(progress: goal.progress),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '$percent% complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BudgetaColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BudgetaColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${remaining.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BudgetaColors.deep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Deadline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BudgetaColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateText(goal.targetDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BudgetaColors.deep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(
    BuildContext context,
    Goal goal,
    num remaining,
    int percent,
  ) {
    final proj = goal.projection;

    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: BudgetaColors.accentLight.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: BudgetaColors.deep,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You\'ve completed $percent% of this goal.\n'
            'Remaining amount: \$${remaining.toStringAsFixed(2)}.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: BudgetaColors.textMuted),
          ),
          const SizedBox(height: 10),
          if (proj == null)
            Text(
              'Ask Budgeta’s AI for an estimated completion date and a suggested monthly saving plan.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: BudgetaColors.textMuted),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI projection',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estimated completion: ${_dateText(proj.estimatedCompletionDate)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: BudgetaColors.deep),
                ),
                const SizedBox(height: 2),
                Text(
                  'Suggested monthly saving: '
                  '\$${proj.suggestedMonthlySaving.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: BudgetaColors.deep),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _dateText(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  Future<void> _openEditGoal(BuildContext context, Goal goal) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GoalEditSheet(goal: goal),
        );
      },
    );
  }
}
