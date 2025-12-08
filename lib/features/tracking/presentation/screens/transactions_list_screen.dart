import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';
import '../../../../shared/bottom_nav.dart';
import '../../../../core/models/transaction.dart';
import '../../state/tracking_cubit.dart';

import '../widgets/transaction_tile.dart';
import '../widgets/category_chip_list.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'recurring_transactions_screen.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  bool _initialized = false;

  TransactionType? _filterType; // null = all
  String? _filterCategoryId; // null = all

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      context.read<TrackingCubit>().loadTransactions();
      _initialized = true;
    }
  }

  void _openRecurring() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RecurringTransactionsScreen(),
      ),
    );
  }

  void _onEdit(Transaction tx) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: tx),
      ),
    );
  }

  Future<void> _onDelete(Transaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<TrackingCubit>().deleteTransactionById(tx.id);
    }
  }

  void _goToDashboardReports() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset tracking data?'),
        content: const Text(
          'This will remove all sample and user transactions/recurring rules '
          'for this profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted) return;

    await context.read<TrackingCubit>().clearAllUserData();
  }

  // ---------------- FILTERS SHEET ----------------

  Future<void> _openFiltersSheet() async {
    TransactionType? tempType = _filterType;
    String? tempCategory = _filterCategoryId;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: StatefulBuilder(
                builder: (ctx, setSheetState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: BudgetaColors.deep,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTypeChip(
                            label: 'All',
                            selected: tempType == null,
                            onTap: () {
                              setSheetState(() => tempType = null);
                            },
                          ),
                          _buildTypeChip(
                            label: 'Expenses',
                            selected: tempType == TransactionType.expense,
                            onTap: () {
                              setSheetState(
                                  () => tempType = TransactionType.expense);
                            },
                          ),
                          _buildTypeChip(
                            label: 'Income',
                            selected: tempType == TransactionType.income,
                            onTap: () {
                              setSheetState(
                                  () => tempType = TransactionType.income);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Category',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: BudgetaColors.deep),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CategoryChipList(
                        selectedCategoryId: tempCategory,
                        onCategorySelected: (id) {
                          setSheetState(() => tempCategory = id);
                        },
                        incomeOnly: false,
                        showAllChip: true,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: BudgetaColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _filterType = tempType;
                              _filterCategoryId = tempCategory;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Apply filters'),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 1),
      floatingActionButton: _ExpandableAddFab(
        onAddExpense: () => showAddTransactionBottomSheet(
          context,
          preselectedType: TransactionType.expense,
        ),
        onAddIncome: () => showAddTransactionBottomSheet(
          context,
          preselectedType: TransactionType.income,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            _TrackingHeader(
              onOpenReports: _goToDashboardReports,
              onOpenRecurring: _openRecurring,
              onClearAll: _clearAllData,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // All Transactions bar + filters summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: BudgetaColors.accentLight
                            .withValues(alpha: 0.15),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'All Transactions 💖',
                            style: TextStyle(
                              color: BudgetaColors.deep,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _openFiltersSheet,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.filter_alt_outlined,
                                  size: 18,
                                  color: BudgetaColors.deep,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _currentFilterLabel(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: BudgetaColors.deep,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                      child: _buildReviewCategoriesBanner(),
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
                            var txs = state.transactions;

                            if (_filterType != null) {
                              txs = txs
                                  .where((t) => t.type == _filterType)
                                  .toList();
                            }

                            if (_filterCategoryId != null) {
                              txs = txs
                                  .where((t) =>
                                      t.categoryId == _filterCategoryId)
                                  .toList();
                            }

                            if (txs.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Text(
                                    'No transactions match your filters yet.\n'
                                    'Try adding a new income or expense.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                  20, 4, 20, 80),
                              itemCount: txs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final t = txs[index];
                                return TransactionTile(
                                  transaction: t,
                                  onTap: () => _onEdit(t),
                                  onDelete: () => _onDelete(t),
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

  // ---------------- Helpers ----------------

  String _currentFilterLabel() {
    final typeLabel = () {
      if (_filterType == TransactionType.expense) return 'Expenses';
      if (_filterType == TransactionType.income) return 'Income';
      return 'All';
    }();

    final catLabel =
        _filterCategoryId == null ? 'All categories' : _filterCategoryId!;
    return '$typeLabel · $catLabel';
  }

  Widget _buildTypeChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: BudgetaColors.accentLight,
      backgroundColor: BudgetaColors.background,
      labelStyle: TextStyle(
        color: selected
            ? BudgetaColors.deep
            : BudgetaColors.deep.withValues(alpha: 0.7),
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected ? BudgetaColors.primary : BudgetaColors.accentLight,
      ),
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildReviewCategoriesBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: BudgetaColors.accentLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.auto_awesome, size: 18, color: BudgetaColors.deep),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Smart categories ON – tap a transaction to review or override its category.',
              style: TextStyle(fontSize: 12, color: BudgetaColors.deep),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- HEADER ----------------

class _TrackingHeader extends StatelessWidget {
  final VoidCallback onOpenReports;
  final VoidCallback onOpenRecurring;
  final VoidCallback onClearAll;

  const _TrackingHeader({
    required this.onOpenReports,
    required this.onOpenRecurring,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9A0E3A),
            Color(0xFFFF4F8B),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense Tracking ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track every penny with sparkle!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'View spending report',
            onPressed: onOpenReports,
            icon: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'recurring') {
                onOpenRecurring();
              } else if (value == 'reset') {
                onClearAll();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'recurring',
                child: Text('Recurring & schedules'),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Text('Reset tracking data'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- EXPANDABLE FAB ----------------

class _ExpandableAddFab extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const _ExpandableAddFab({
    required this.onAddIncome,
    required this.onAddExpense,
  });

  @override
  State<_ExpandableAddFab> createState() => _ExpandableAddFabState();
}

class _ExpandableAddFabState extends State<_ExpandableAddFab> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      height: 180,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if (_expanded)
            Positioned(
              right: 0,
              bottom: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AddRow(
                    label: 'Add Income',
                    color: Colors.green.shade600,
                    icon: Icons.arrow_upward,
                    onPressed: () {
                      setState(() => _expanded = false);
                      widget.onAddIncome();
                    },
                  ),
                  const SizedBox(height: 8),
                  _AddRow(
                    label: 'Add Expense',
                    color: BudgetaColors.primary,
                    icon: Icons.arrow_downward,
                    onPressed: () {
                      setState(() => _expanded = false);
                      widget.onAddExpense();
                    },
                  ),
                ],
              ),
            ),
          FloatingActionButton(
            heroTag: 'tracking_add_fab',
            backgroundColor: BudgetaColors.primary,
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Icon(_expanded ? Icons.close : Icons.add),
          ),
        ],
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _AddRow({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: BudgetaColors.deep,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        FloatingActionButton.small(
          heroTag: 'add_row_$label',
          backgroundColor: color,
          onPressed: onPressed,
          child: Icon(icon),
        ),
      ],
    );
  }
}
