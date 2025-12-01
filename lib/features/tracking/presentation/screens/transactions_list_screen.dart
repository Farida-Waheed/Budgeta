import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/bottom_nav.dart';
import '../../../../app/theme.dart';
import '../../state/tracking_cubit.dart';
import '../../../../core/models/transaction.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/category_chip_list.dart';

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
    // For now just pop back to main (dashboard tab)
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all tracking data?'),
        content: const Text(
          'This will remove the demo examples and any transactions/recurring '
          'rules you added for this user.',
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
    if (!mounted) return;

    await context.read<TrackingCubit>().clearAllUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'View spending report',
            onPressed: _goToDashboardReports,
          ),
          IconButton(
            icon: const Icon(Icons.repeat),
            tooltip: 'Recurring & schedules',
            onPressed: _openRecurring,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') _clearAllData();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'clear',
                child: Text('Clear demo & user data'),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 1),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildTypeFilterRow(),
          const SizedBox(height: 8),
          CategoryChipList(
            selectedCategoryId: _filterCategoryId,
            onCategorySelected: (id) {
              setState(() {
                _filterCategoryId = id;
              });
            },
            incomeOnly: false,
            showAllChip: true,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildReviewCategoriesBanner(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TrackingCubit, TrackingState>(
              builder: (context, state) {
                if (state is TrackingLoading || state is TrackingInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TrackingError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is TrackingLoaded) {
                  var txs = state.transactions;

                  if (_filterType != null) {
                    txs = txs
                        .where((t) => t.type == _filterType)
                        .toList();
                  }

                  if (_filterCategoryId != null) {
                    txs = txs
                        .where((t) => t.categoryId == _filterCategoryId)
                        .toList();
                  }

                  if (txs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No transactions match your filters yet.\n'
                        'Try adding a new income or expense.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: txs.length,
                    separatorBuilder: (_, index) =>
                        const SizedBox(height: 8),
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
    );
  }

  Widget _buildTypeFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BudgetaColors.accentLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTypeChip(
              label: 'All',
              selected: _filterType == null,
              onTap: () {
                setState(() {
                  _filterType = null;
                });
              },
            ),
            _buildTypeChip(
              label: 'Expenses',
              selected: _filterType == TransactionType.expense,
              onTap: () {
                setState(() {
                  _filterType = TransactionType.expense;
                });
              },
            ),
            _buildTypeChip(
              label: 'Income',
              selected: _filterType == TransactionType.income,
              onTap: () {
                setState(() {
                  _filterType = TransactionType.income;
                });
              },
            ),
          ],
        ),
      ),
    );
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
        color:
            selected ? BudgetaColors.deep : BudgetaColors.deep.withOpacity(0.7),
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
