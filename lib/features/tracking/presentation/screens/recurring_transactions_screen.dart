// lib/features/tracking/presentation/screens/recurring_transactions_screen.dart
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
      backgroundColor: BudgetaColors.backgroundLight,
      floatingActionButton: _AddRecurringFab(
        onPressed: () => _openAddOrEditRuleDialog(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            _RecurringHeader(
              title: 'Recurring & Schedules',
              subtitle: 'Automate your financial habits ✨',
            ),
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
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is TrackingError) {
                            return Center(
                              child: Text('Error: ${state.message}'),
                            );
                          } else if (state is TrackingLoaded) {
                            final rules = state.recurringRules;
                            if (rules.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    'No recurring transactions yet.\n\n'
                                    'Use the + button to set up rent, salary or subscriptions.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: BudgetaColors.deep),
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                              itemCount: rules.length,
                              itemBuilder: (context, index) {
                                final r = rules[index];
                                return _RecurringRuleTile(
                                  rule: r,
                                  onEdit: () => _openAddOrEditRuleDialog(
                                    context,
                                    existing: r,
                                  ),
                                );
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

  Widget _buildInfoCard() {
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

  /// Opens the dialog in either "add" or "edit" mode.
  /// If [existing] is null → Add, otherwise Edit.
  void _openAddOrEditRuleDialog(
    BuildContext context, {
    RecurringRule? existing,
  }) {
    final existingRule = existing;
    final isEditing = existingRule != null;

    final amountController = TextEditingController(
      text: existingRule != null ? existingRule.amount.toStringAsFixed(2) : '',
    );

    RecurringFrequency frequency =
        existingRule?.frequency ?? RecurringFrequency.monthly;
    String categoryId = existingRule?.categoryId ?? 'rent';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Center(
            child: Container(
              // outer gradient frame – same vibe as dashboard header
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9A0E3A), Color(0xFFFF4F8B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2), // tiny gradient border
              child: Container(
                decoration: BoxDecoration(
                  color: BudgetaColors.backgroundLight,
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: StatefulBuilder(
                  builder: (ctx, setSheetState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // drag handle
                        Center(
                          child: Container(
                            width: 48,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEditing
                                        ? 'Edit Recurring Transaction ✨'
                                        : 'Add Recurring Transaction ✨',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: BudgetaColors.deep,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Automate your money habits with a few taps.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: BudgetaColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: BudgetaColors.deep,
                              ),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: BudgetaColors.deep,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                            hintText: '0.00',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: BudgetaColors.accentLight.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Frequency',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: BudgetaColors.deep,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<RecurringFrequency>(
                          initialValue: frequency,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: BudgetaColors.accentLight.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
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
                          onChanged: (val) {
                            if (val == null) return;
                            setSheetState(() => frequency = val);
                          },
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: BudgetaColors.deep,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: categoryId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: BudgetaColors.accentLight.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
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
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setSheetState(() => categoryId = val);
                          },
                        ),

                        const SizedBox(height: 22),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: BudgetaColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            _GradientPrimaryButton(
                              label: isEditing ? 'Save changes' : 'Save',
                              onPressed: () {
                                final raw = amountController.text.trim();
                                final parsed = double.tryParse(raw);
                                if (parsed == null || parsed <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a valid amount.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // 👉 For now this is only UI.
                                // Wire this to your TrackingCubit when
                                // you add add/update methods.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEditing
                                          ? 'Recurring rule edited (demo only).'
                                          : 'Recurring rule saved (demo only).',
                                    ),
                                  ),
                                );

                                Navigator.of(ctx).pop();
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Header Component
// ---------------------------------------------------------------------------

class _RecurringHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RecurringHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.18;

    return Container(
      height: headerHeight,
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Icon(Icons.repeat, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom FAB Component
// ---------------------------------------------------------------------------

class _AddRecurringFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddRecurringFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureRecognizer(onTap: onPressed);
  }
}

class GestureRecognizer extends StatelessWidget {
  final VoidCallback onTap;

  const GestureRecognizer({super.key, required this.onTap});

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
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Tile Component
// ---------------------------------------------------------------------------

class _RecurringRuleTile extends StatelessWidget {
  final RecurringRule rule;
  final VoidCallback onEdit;

  const _RecurringRuleTile({required this.rule, required this.onEdit});

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
        onTap: onEdit,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

// ---------------------------------------------------------------------------
// Shared gradient primary button (used in dialog)
// ---------------------------------------------------------------------------

class _GradientPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientPrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9A0E3A), Color(0xFFFF4F8B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
