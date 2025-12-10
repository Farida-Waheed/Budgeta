// lib/features/goals/presentation/screens/goals_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';

// shared core widgets
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/modal_sheet.dart';
import '../../../../core/widgets/text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/bottom_nav.dart';

// models + state
import '../../../../core/models/goal.dart';
import '../../state/goals_cubit.dart';
import '../../data/goals_repository.dart';

class GoalsHomeScreen extends StatelessWidget {
  const GoalsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GoalsCubit(repository: InMemoryGoalsRepository(), userId: 'demo-user')
            ..loadGoals(),
      child: const _GoalsHomeView(),
    );
  }
}

class _GoalsHomeView extends StatefulWidget {
  const _GoalsHomeView(); // key not needed

  @override
  State<_GoalsHomeView> createState() => _GoalsHomeViewState();
}

class _GoalsHomeViewState extends State<_GoalsHomeView> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _currentCtrl = TextEditingController(text: '0');
  DateTime? _deadline;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const MagicGradientHeader(
              title: 'Savings Goals 💰',
              subtitle: 'Your dreams are just a sparkle away!',
              trailingIcon: Icons.more_vert,
            ),
            Expanded(
              child: BlocBuilder<GoalsCubit, GoalsState>(
                builder: (context, state) {
                  if (state is GoalsInitial || state is GoalsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is GoalsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Couldn\'t load goals.\n${state.message}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final loaded = state as GoalsLoaded;
                  final goals = loaded.goals;

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MagicSectionTitle('Your Treasure Quests ✨'),
                            const SizedBox(height: 16),
                            if (goals.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
                                child: Text(
                                  'No goals yet.\nTap the + button to start your first quest ✨',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: BudgetaColors.textMuted,
                                      ),
                                ),
                              )
                            else
                              for (int i = 0; i < goals.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14.0),
                                  child: _GoalCard(
                                    goal: goals[i],
                                    isFirst: i == 0,
                                  ),
                                ),
                          ],
                        ),
                      ),

                      // FAB inside scroll area (bottom-right)
                      Positioned(
                        right: 24,
                        bottom: 16,
                        child: _AddGoalFab(onTap: _openCreateGoalSheet),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 2),
    );
  }

  Future<void> _openCreateGoalSheet() async {
    _nameCtrl.clear();
    _targetCtrl.clear();
    _currentCtrl.text = '0';
    _deadline = null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: MagicModalSheet(
            title: 'Create Goal ✨',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                MagicTextField(label: 'Goal Name', controller: _nameCtrl),
                const SizedBox(height: 12),
                MagicTextField(
                  label: 'Target Amount',
                  controller: _targetCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                MagicTextField(
                  label: 'Current Savings (Optional)',
                  controller: _currentCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),

                // Deadline picker
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Deadline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BudgetaColors.textMuted,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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
                PrimaryButton(
                  label: 'Create Goal 💞',
                  onPressed: _handleCreateGoal,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _handleCreateGoal() {
    final name = _nameCtrl.text.trim();
    final target = double.tryParse(_targetCtrl.text.trim()) ?? 0;
    final current = double.tryParse(_currentCtrl.text.trim()) ?? 0;

    if (name.isEmpty || target <= 0) {
      Navigator.of(context).pop();
      return;
    }

    context.read<GoalsCubit>().createGoal(
      name: name,
      target: target,
      current: current,
      deadline: _deadline,
    );

    Navigator.of(context).pop();
  }
}

/// Small gradient FAB matching other screens (+)
class _AddGoalFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddGoalFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFFF9617D), Color(0xFFB3125D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

/// Goal card bound to the real `Goal` model
class _GoalCard extends StatelessWidget {
  final Goal goal;
  final bool isFirst;

  const _GoalCard({required this.goal, required this.isFirst});

  String _deadlineText() {
    if (goal.targetDate == null) return '—';
    final d = goal.targetDate!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress.isNaN ? 0.0 : goal.progress;
    final progressPercent = (progress * 100).round();
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(
      0,
      goal.targetAmount,
    );

    return MagicCard(
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BudgetaColors.accentLight.withValues(alpha: 0.18),
                ),
                child: const Icon(
                  Icons.radio_button_unchecked,
                  size: 18,
                  color: BudgetaColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  goal.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '\$${goal.currentAmount.toStringAsFixed(2)}'
                ' of \$${goal.targetAmount.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: BudgetaColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar & % label
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: const Color(0xFFFFEEF3)),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: BudgetaColors.deep),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$progressPercent% complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BudgetaColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Remaining + Deadline row
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
                    _deadlineText(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BudgetaColors.deep,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (isFirst || progress >= 0.9)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BudgetaColors.accentLight.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '✨ Almost there! Keep sparkling! ✨',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
