// lib/features/tracking/presentation/screens/transactions_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../shared/bottom_nav.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/models/tracking_summary.dart';
import '../../state/tracking_cubit.dart';

import '../widgets/transaction_tile.dart';
import '../widgets/category_chip_list.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'recurring_transactions_screen.dart';
import 'category_rules_screen.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
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
      MaterialPageRoute(builder: (_) => const RecurringTransactionsScreen()),
    );
  }

  Future<void> _onEdit(Transaction tx) async {
    await showEditTransactionBottomSheet(context, transaction: tx);
  }

  Future<void> _onDelete(Transaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<TrackingCubit>().deleteTransactionById(tx.id);
    }
  }

  void _goToDashboardReports() {
    // back to first (dashboard) route
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    await context.read<TrackingCubit>().clearAllUserData();
  }

  // ---------- OPEN CATEGORY RULES (ADMIN) ----------

  void _openCategoryRules() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryRulesScreen()),
    );
  }

  // ---------- RUN RECURRING NOW ----------

  Future<void> _runRecurringNow() async {
    final cubit = context.read<TrackingCubit>();
    final created = await cubit.processRecurringForToday();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created == 0
              ? 'No recurring transactions were due today.'
              : 'Auto-posted $created recurring transaction(s).',
        ),
      ),
    );
  }

  // ---------- QUICK SUMMARY ----------

  Future<void> _showQuickSummary() async {
    final cubit = context.read<TrackingCubit>();
    late TrackingSummary summary;

    try {
      summary = await cubit.getSummary();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load summary: $e')));
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        final net = summary.totalIncome - summary.totalExpense;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Quick Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('Income', summary.totalIncome),
              const SizedBox(height: 4),
              _summaryRow('Expenses', summary.totalExpense),
              const SizedBox(height: 4),
              _summaryRow('Net', net),
              const SizedBox(height: 12),
              const Text(
                'Per category (top few):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...summary.perCategoryTotals.entries
                  .take(5)
                  .map(
                    (e) => Text(
                      '• ${_capitalize(e.key)}: ${e.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  static Widget _summaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // ---------- EXPORT CSV ----------

  Future<void> _exportCsv() async {
    final cubit = context.read<TrackingCubit>();

    String csv;
    try {
      csv = await cubit.exportCsv(
        // could also pass filters here if you want export = current view:
        categoryId: _filterCategoryId,
        type: _filterType,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to export CSV: $e')));
      return;
    }

    if (!mounted) return;

    // For MVP: just show the CSV in a dialog so it can be copied.
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Exported CSV'),
          content: SizedBox(
            width: double.maxFinite,
            height: 250,
            child: SingleChildScrollView(
              child: SelectableText(csv, style: const TextStyle(fontSize: 11)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ---------------- FILTERS SHEET ----------------

  Future<void> _openFiltersSheet() async {
    TransactionType? tempType = _filterType;
    String? tempCategory = _filterCategoryId;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: BudgetaColors.backgroundLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: StatefulBuilder(
                  builder: (ctx, setSheetState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // drag handle
                        Container(
                          width: 48,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: BudgetaColors.accentLight.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: BudgetaColors.deep,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // type chips
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
                                  () => tempType = TransactionType.expense,
                                );
                              },
                            ),
                            _buildTypeChip(
                              label: 'Income',
                              selected: tempType == TransactionType.income,
                              onTap: () {
                                setSheetState(
                                  () => tempType = TransactionType.income,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // category label
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Category',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: BudgetaColors.deep,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // category chips
                        CategoryChipList(
                          selectedCategoryId: tempCategory,
                          onCategorySelected: (id) {
                            setSheetState(() => tempCategory = id);
                          },
                          incomeOnly: false,
                          showAllChip: true,
                        ),
                        const SizedBox(height: 22),

                        // buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: BudgetaColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      BudgetaColors.primary,
                                      BudgetaColors.deep,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _filterType = tempType;
                                      _filterCategoryId = tempCategory;
                                    });
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text(
                                    'Apply filters',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
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

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 1),

      // Main FAB on the right (matches recurring/gamification style)
      floatingActionButton: _MainAddFab(
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
        // 🔹 Let the gradient header paint under the status bar
        top: false,
        child: Column(
          children: [
            _TrackingHeader(
              onOpenReports: _goToDashboardReports,
              onOpenRecurring: _openRecurring,
              onClearAll: _clearAllData,
              onOpenCategoryRules: _openCategoryRules,
              onRunRecurringNow: _runRecurringNow,
              onShowSummary: _showQuickSummary,
              onExportCsv: _exportCsv,
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: BudgetaColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
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
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is TrackingError) {
                            return Center(
                              child: Text('Error: ${state.message}'),
                            );
                          } else if (state is TrackingLoaded) {
                            var txs = state.transactions;

                            if (_filterType != null) {
                              txs = txs
                                  .where((t) => t.type == _filterType)
                                  .toList();
                            }

                            if (_filterCategoryId != null) {
                              txs = txs
                                  .where(
                                    (t) => t.categoryId == _filterCategoryId,
                                  )
                                  .toList();
                            }

                            if (txs.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Text(
                                    'No transactions match your filters yet.\n'
                                    'Try adding a new income or expense.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
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

    final catLabel = _filterCategoryId == null
        ? 'All categories'
        : _filterCategoryId!;
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BudgetaColors.accentLight.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
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

  final VoidCallback onOpenCategoryRules;
  final Future<void> Function() onRunRecurringNow;
  final Future<void> Function() onShowSummary;
  final Future<void> Function() onExportCsv;

  const _TrackingHeader({
    required this.onOpenReports,
    required this.onOpenRecurring,
    required this.onClearAll,
    required this.onOpenCategoryRules,
    required this.onRunRecurringNow,
    required this.onShowSummary,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Include status bar padding so the header is tall & consistent
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [BudgetaColors.primary, BudgetaColors.deep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 12,
        top: topPadding + 16,
        bottom: 24,
      ),
      constraints: const BoxConstraints(minHeight: 110),
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
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'View spending report',
            onPressed: onOpenReports,
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'recurring':
                  onOpenRecurring();
                  break;
                case 'rules':
                  onOpenCategoryRules();
                  break;
                case 'runRecurring':
                  await onRunRecurringNow();
                  break;
                case 'summary':
                  await onShowSummary();
                  break;
                case 'export':
                  await onExportCsv();
                  break;
                case 'reset':
                  onClearAll();
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'recurring',
                child: Row(
                  children: [
                    Icon(Icons.repeat, size: 18),
                    SizedBox(width: 8),
                    Text('Recurring & schedules'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rules',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18),
                    SizedBox(width: 8),
                    Text('Category auto-rules'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'runRecurring',
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, size: 18),
                    SizedBox(width: 8),
                    Text('Run recurring now'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'summary',
                child: Row(
                  children: [
                    Icon(Icons.summarize_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Quick summary'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Reset tracking data',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- MAIN ADD FAB (right side with menu) ----------------

class _MainAddFab extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const _MainAddFab({required this.onAddIncome, required this.onAddExpense});

  @override
  State<_MainAddFab> createState() => _MainAddFabState();
}

class _MainAddFabState extends State<_MainAddFab> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          if (_open)
            Positioned(
              right: 70,
              bottom: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _FabActionRow(
                    label: 'Add Income',
                    color: Colors.green,
                    icon: Icons.arrow_upward,
                    onTap: () {
                      setState(() => _open = false);
                      widget.onAddIncome();
                    },
                  ),
                  const SizedBox(height: 10),
                  _FabActionRow(
                    label: 'Add Expense',
                    color: BudgetaColors.primary,
                    icon: Icons.arrow_downward,
                    onTap: () {
                      setState(() => _open = false);
                      widget.onAddExpense();
                    },
                  ),
                ],
              ),
            ),

          // main circular FAB
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [BudgetaColors.primary, BudgetaColors.deep],
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
                child: Icon(
                  _open ? Icons.close : Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FabActionRow extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _FabActionRow({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
