import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';

// shared core widgets
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/modal_sheet.dart';
import '../../../../core/widgets/text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/bottom_nav.dart';

// models + state
import '../../../../core/models/goal.dart';
import '../../state/goals_cubit.dart';
import '../../data/goals_repository.dart';

// local widgets/screens
import '../../../goals/presentation/widgets/goal_card.dart';
import '../../../goals/presentation/screens/goal_detail_screen.dart';
import 'goal_edit_screen.dart';

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
  const _GoalsHomeView();

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
                            // Header under gradient – match "All Transactions 💖"
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                'Your Treasure Quests ✨',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: BudgetaColors.deep,
                                    ),
                              ),
                            ),
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
                                  child: GoalCard(
                                    goal: goals[i],
                                    isFirst: i == 0,
                                    onTap: () => _openGoalDetails(goals[i]),
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

  // ---------- Create Goal ----------

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

  // ---------- Details & Edit ----------

  Future<void> _openGoalDetails(Goal goal) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GoalDetailsSheet(
            goalId: goal.id,
            onEdit: () {
              Navigator.of(context).pop(); // close details
              _openEditGoal(goal);
            },
          ),
        );
      },
    );
  }

  Future<void> _openEditGoal(Goal goal) async {
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
