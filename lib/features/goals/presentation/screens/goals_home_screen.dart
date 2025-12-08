// lib/features/goals/presentation/screens/goals_home_screen.dart
import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';

// shared core widgets
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/bottom_nav.dart';
import '../../../../core/widgets/fab.dart';
import '../../../../core/widgets/modal_sheet.dart';
import '../../../../core/widgets/text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class GoalsHomeScreen extends StatefulWidget {
  const GoalsHomeScreen({super.key});

  @override
  State<GoalsHomeScreen> createState() => _GoalsHomeScreenState();
}

class _GoalsHomeScreenState extends State<GoalsHomeScreen> {
  // This index is for the *main* app nav (Home, Tracking, Goals, Coach, Community)
  // In the main nav, 0=Home, 1=Tracking, 2=Goals, 3=Coach, 4=Community
  static const int _navIndex = 2;

  // Very small in-memory fake data just to render the UI
  final List<_GoalViewModel> _goals = [
    _GoalViewModel(
      title: '✨ d',
      current: 5,
      target: 5,
      deadline: '—',
      showEncouragement: true,
    ),
    _GoalViewModel(
      title: 'Dream Vacation',
      current: 1250,
      target: 5000,
      deadline: '01/06/2026',
    ),
    _GoalViewModel(
      title: 'Emergency Fund',
      current: 3200,
      target: 10000,
      deadline: '03/12/2026',
    ),
  ];

  // Controllers for the “Create Goal” sheet
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _currentCtrl = TextEditingController(text: '0');

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

      // Gradient header like in the mock
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const MagicGradientHeader(
                  title: 'Savings Goals 💰',
                  subtitle: 'Your dreams are just a sparkle away!',
                  trailingIcon: Icons.more_vert, // or Icons.auto_awesome if you prefer
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MagicSectionTitle("Your Treasure Quests ✨"),
                        const SizedBox(height: 16),
                        for (int i = 0; i < _goals.length; i++)
                          _GoalCard(
                            goal: _goals[i],
                            isFirst: i == 0,
                          ),
                        const SizedBox(height: 80), // space above FAB + nav
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating "+" FAB (inside content area like the mock)
            Positioned(
              right: 24,
              bottom: 90, // above the bottom nav
              child: MagicFab(
                icon: Icons.add,
                onPressed: _openCreateGoalSheet,
              ),
            ),
          ],
        ),
      ),

      // Shared main bottom nav
      bottomNavigationBar: MagicBottomNav(
        currentIndex: _navIndex,
        items: kMainNavItems,
        onTap: _handleMainNavTap,
      ),
    );
  }

  void _handleMainNavTap(int index) {
    if (index == _navIndex) return; // already on Goals

    String route;
    switch (index) {
      case 0:
        route = AppRoutes.dashboard;
        break;
      case 1:
        route = AppRoutes.transactions;
        break;
      case 2:
        route = AppRoutes.goals;
        break;
      case 3:
        route = AppRoutes.coach;
        break;
      case 4:
      default:
        route = AppRoutes.community;
        break;
    }

    Navigator.pushReplacementNamed(context, route);
  }

  void _openCreateGoalSheet() {
    _nameCtrl.clear();
    _targetCtrl.clear();
    _currentCtrl.text = '0';

    showModalBottomSheet(
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
                MagicTextField(
                  label: 'Goal Name',
                  controller: _nameCtrl,
                ),
                const SizedBox(height: 12),
                MagicTextField(
                  label: 'Target Amount',
                  controller: _targetCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                MagicTextField(
                  label: 'Current Savings (Optional)',
                  controller: _currentCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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

  void _handleCreateGoal() {
    final name = _nameCtrl.text.trim();
    final target = double.tryParse(_targetCtrl.text.trim()) ?? 0;
    final current = double.tryParse(_currentCtrl.text.trim()) ?? 0;

    if (name.isEmpty || target <= 0) {
      // very lightweight validation
      Navigator.of(context).pop(); // just close for now
      return;
    }

    setState(() {
      _goals.insert(
        0,
        _GoalViewModel(
          title: name,
          current: current,
          target: target,
          deadline: '—',
          showEncouragement: current >= target,
        ),
      );
    });

    Navigator.of(context).pop();
  }
}

/// Simple view-model for the UI
class _GoalViewModel {
  final String title;
  final double current;
  final double target;
  final String deadline;
  final bool showEncouragement;

  const _GoalViewModel({
    required this.title,
    required this.current,
    required this.target,
    required this.deadline,
    this.showEncouragement = false,
  });

  double get progress =>
      target <= 0 ? 0 : (current / target).clamp(0, 1).toDouble();

  double get remaining => (target - current).clamp(0, target);
}

/// One goal card UI – styled to match the Figma
class _GoalCard extends StatelessWidget {
  final _GoalViewModel goal;
  final bool isFirst;

  const _GoalCard({
    required this.goal,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (goal.progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: BudgetaColors.cardBorder.withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                  color: BudgetaColors.accentLight.withOpacity(0.18),
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
                  goal.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BudgetaColors.deep,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '\$${goal.current.toStringAsFixed(2)}'
                ' of \$${goal.target.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BudgetaColors.textMuted,
                    ),
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
                  Container(
                    color: const Color(0xFFFFEEF3),
                  ),
                  FractionallySizedBox(
                    widthFactor: goal.progress,
                    child: Container(
                      color: BudgetaColors.deep,
                    ),
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
                    '\$${goal.remaining.toStringAsFixed(2)}',
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
                    goal.deadline,
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

          // Pink encouragement pill (only for first or when flag is true)
          if (isFirst || goal.showEncouragement)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BudgetaColors.accentLight.withOpacity(0.28),
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