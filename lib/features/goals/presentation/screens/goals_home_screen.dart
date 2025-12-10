// lib/features/goals/presentation/screens/goals_home_screen.dart
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
import '../widgets/goal_card.dart';
import 'goal_detail_screen.dart';
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
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 2),

      // FAB: same size & placement as Expense Tracking main +
      floatingActionButton: _AddGoalFab(onTap: _openCreateGoalSheet),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

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

                  // Match Tracking: rounded container + top bar
                  return Container(
                    decoration: const BoxDecoration(
                      color: BudgetaColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Upper bar – same style as "All Transactions 💖"
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: BudgetaColors.accentLight.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Your Treasure Quests ✨',
                            style: TextStyle(
                              color: BudgetaColors.deep,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        // Content
                        Expanded(
                          child: goals.isEmpty
                              // ---------- EMPTY STATE: centered ----------
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                    ),
                                    child: Text(
                                      'No goals yet.\nTap the + button to start your first quest ✨',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: BudgetaColors.textMuted,
                                      ),
                                    ),
                                  ),
                                )
                              // ---------- LIST OF GOALS ----------
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    20,
                                    80,
                                  ),
                                  child: Column(
                                    children: [
                                      for (int i = 0; i < goals.length; i++)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 14.0,
                                          ),
                                          child: GoalCard(
                                            goal: goals[i],
                                            isFirst: i == 0,
                                            onTap: () =>
                                                _openGoalDetails(goals[i]),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
          child: GoalDetailsSheet(goalId: goal.id),
        );
      },
    );
  }
}

/// FAB – same circle as Expense Tracking main plus
class _AddGoalFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddGoalFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF4F8B), Color(0xFF9A0E3A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
