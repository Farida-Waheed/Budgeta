import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/recurring_rule.dart';
import '../../../../shared/bottom_nav.dart';
import '../../state/tracking_cubit.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 1),
      floatingActionButton: _AddRecurringFab(
        onPressed: () => _openAddRuleDialog(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            const _RecurringHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: BudgetaColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                      child: _buildInfoCard(),
                    ),
                    Expanded(
                      child: BlocBuilder<TrackingCubit, TrackingState>(
                        builder: (context, state) {
                          if (state is TrackingLoading ||
                              state is TrackingInitial) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is TrackingError) {
                            return Center(
                                child: Text('Error: ${state.message}'));
                          } else if (state is TrackingLoaded) {
                            final rules = state.recurringRules;
                            if (rules.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    'No recurring transactions yet.\n\n'
                                    'Use the + button to set up rent, salary or subscriptions.',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(color: BudgetaColors.deep),
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 80),
                              itemCount: rules.length,
                              itemBuilder: (context, index) {
                                final r = rules[index];
                                return _RecurringRuleTile(rule: r);
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4ED), Color(0xFFFDF4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.notifications_active_outlined,
              color: BudgetaColors.deep,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Recurring rules are your fixed money habits: rent, salary, '
              'subscriptions… Your AI Coach and alerts will use these to '
              'remind you before payments are due.',
              style: TextStyle(fontSize: 12, color: BudgetaColors.deep),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Add recurring dialog (same logic as before)
  // ---------------------------------------------------------------------------
  static void _openAddRuleDialog(BuildContext context) {
    final amountController = TextEditingController();
    RecurringFrequency frequency = RecurringFrequency.monthly;
    String categoryId = 'rent';
    bool customCategory = false;
    final customCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: BudgetaColors.primary,
                ),
          ),
          child: AlertDialog(
            backgroundColor: BudgetaColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            titleTextStyle: const TextStyle(
              color: BudgetaColors.deep,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            contentTextStyle: const TextStyle(
              color: BudgetaColors.deep,
              fontSize: 14,
            ),
            title: const Text('Add Recurring Transaction'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<RecurringFrequency>(
                        value: frequency,
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: RecurringFrequency.daily,
                            child: Text('Daily'),
                          ),
                          DropdownMenuItem(
                            value: RecurringFrequency.weekly,
                            child: Text('Weekly'),
                          ),
                          DropdownMenuItem(
                            value: RecurringFrequency.monthly,
                            child: Text('Monthly'),
                          ),
                          DropdownMenuItem(
                            value: RecurringFrequency.yearly,
                            child: Text('Yearly'),
                          ),
                        ],
                        onChanged: (f) {
                          if (f != null) setState(() => frequency = f);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: categoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'rent',
                            child: Text('Rent'),
                          ),
                          DropdownMenuItem(
                            value: 'salary',
                            child: Text('Salary'),
                          ),
                          DropdownMenuItem(
                            value: 'subscription',
                            child: Text('Subscription'),
                          ),
                          DropdownMenuItem(
                            value: 'transport',
                            child: Text('Transport'),
                          ),
                          DropdownMenuItem(
                            value: 'custom',
                            child: Text('Other…'),
                          ),
                        ],
                        onChanged: (c) {
                          if (c == null) return;
                          if (c == 'custom') {
                            setState(() {
                              customCategory = true;
                            });
                          } else {
                            setState(() {
                              customCategory = false;
                              categoryId = c;
                            });
                          }
                        },
                      ),
                      if (customCategory) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: customCategoryController,
                          decoration: const InputDecoration(
                            labelText: 'Custom category name',
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding: const EdgeInsets.only(
              right: 16,
              bottom: 16,
              left: 16,
              top: 8,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: BudgetaColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a valid amount'),
                      ),
                    );
                    return;
                  }

                  String finalCategoryId = categoryId;
                  if (customCategory) {
                    final name =
                        customCategoryController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Enter a custom category name'),
                        ),
                      );
                      return;
                    }
                    finalCategoryId = name
                        .toLowerCase()
                        .replaceAll(RegExp(r'\s+'), '_');
                  }

                  final cubit = context.read<TrackingCubit>();
                  final rule = RecurringRule(
                    id: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
                    userId: cubit.userId,
                    amount: amount,
                    startDate: DateTime.now(),
                    frequency: frequency,
                    categoryId: finalCategoryId,
                  );

                  cubit.addNewRecurringRule(rule);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header (same vibe as tracking header, but with back arrow)
// ---------------------------------------------------------------------------

class _RecurringHeader extends StatelessWidget {
  const _RecurringHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9A0E3A), Color(0xFFFF4F8B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.repeat,
                color: Colors.white,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Recurring & Schedules',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Automate your financial habits ✨',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAB and tile
// ---------------------------------------------------------------------------

class _AddRecurringFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddRecurringFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
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
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _RecurringRuleTile extends StatelessWidget {
  final RecurringRule rule;

  const _RecurringRuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    final isIncomeLike = rule.categoryId == 'salary';

    final chipColor = isIncomeLike
        ? Colors.green.withValues(alpha: 0.12)
        : BudgetaColors.primary.withValues(alpha: 0.08);

    return Card(
      elevation: 2,
      shadowColor: BudgetaColors.primary.withValues(alpha: 0.1),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: BudgetaColors.accentLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rule.categoryId,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isIncomeLike
                      ? Colors.green.shade700
                      : BudgetaColors.deep,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isIncomeLike ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: isIncomeLike ? Colors.green.shade700 : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              rule.amount.toStringAsFixed(2),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${_freqLabel(rule.frequency)} • since '
          '${rule.startDate.toLocal().toString().split(' ').first}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.isActive,
              onChanged: (_) {
                context.read<TrackingCubit>().toggleRecurringRule(rule.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete',
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete recurring rule?'),
        content: Text(
          'Are you sure you want to delete this recurring transaction?\n'
          '${rule.categoryId} • ${rule.amount.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TrackingCubit>().deleteRecurringRule(rule.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  static String _freqLabel(RecurringFrequency f) {
    switch (f) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }
}
