import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/recurring_rule.dart';
import '../../state/tracking_cubit.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        title: const Text('Recurring & Schedules'),
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear all recurring rules',
            onPressed: () => _clearAllRecurring(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddRuleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add recurring'),
        backgroundColor: BudgetaColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildInfoCard(),
          ),
          Expanded(
            child: BlocBuilder<TrackingCubit, TrackingState>(
              builder: (context, state) {
                if (state is TrackingLoading || state is TrackingInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TrackingError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is TrackingLoaded) {
                  final rules = state.recurringRules;
                  if (rules.isEmpty) {
                    return const Center(
                      child: Text(
                        'No recurring transactions yet.\nUse the button below to set your first schedule.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BudgetaColors.accentLight),
      ),
      child: Row(
        children: const [
          Icon(Icons.notifications_active_outlined,
              color: BudgetaColors.deep),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Recurring transactions represent your fixed schedules '
              '(rent, subscriptions, salary). Reminders and alerts are '
              'driven from these rules in the coach/notifications subsystem.',
              style: TextStyle(fontSize: 12, color: BudgetaColors.deep),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllRecurring(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all recurring rules?'),
        content: const Text(
          'This removes demo rules and any recurring schedules you added.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    await context.read<TrackingCubit>().clearAllUserData();
  }

  void _openAddRuleDialog(BuildContext context) {
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
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<RecurringFrequency>(
                        initialValue: frequency,
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
                        initialValue: 'rent',
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
            actionsAlignment: MainAxisAlignment.end,
            actionsPadding:
                const EdgeInsets.only(right: 16, bottom: 16, top: 8),
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
                  final amount =
                      double.tryParse(amountController.text);
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

class _RecurringRuleTile extends StatelessWidget {
  final RecurringRule rule;

  const _RecurringRuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          '${rule.categoryId} • ${rule.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_freqLabel(rule.frequency)} • since '
          '${rule.startDate.toLocal().toString().split(' ').first}',
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
