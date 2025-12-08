import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/transaction.dart';
import '../../state/tracking_cubit.dart';
import '../widgets/category_chip_list.dart';

/// ------------------------------------------------------------------
/// PUBLIC API
/// ------------------------------------------------------------------
/// 1) Route screen (used by AppRoutes.addTransaction)
///    → shows the card as a sheet that slides from bottom.
/// 2) Helper function showAddTransactionBottomSheet(...)
///    → to open the same widget from any other screen.
/// ------------------------------------------------------------------

class AddTransactionScreen extends StatelessWidget {
  final TransactionType? preselectedType;

  const AddTransactionScreen({super.key, this.preselectedType});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      // dimmed background like a modal
      backgroundColor: Colors.black.withValues(alpha: 0.35),
      body: SafeArea(
        child: Stack(
          children: [
            // tap outside to close
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
                child: AddTransactionSheet(
                  preselectedType: preselectedType,
                  onClose: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Call this from anywhere you want a classic bottomSheet:
Future<void> showAddTransactionBottomSheet(
  BuildContext context, {
  TransactionType? preselectedType,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      return Padding(
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: AddTransactionSheet(
          preselectedType: preselectedType,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      );
    },
  );
}

/// ------------------------------------------------------------------
/// SHEET WIDGET (HEADER + CARD + FORM)
/// ------------------------------------------------------------------

class AddTransactionSheet extends StatefulWidget {
  final TransactionType? preselectedType;
  final VoidCallback? onClose;

  const AddTransactionSheet({super.key, this.preselectedType, this.onClose});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _date = DateTime.now();
  late TransactionType _type;
  String _selectedCategoryId = 'food';

  String? _suggestedCategoryId;
  bool _receiptAttached = false;

  @override
  void initState() {
    super.initState();
    _type = widget.preselectedType ?? TransactionType.expense;
    _noteController.addListener(_updateSuggestedCategory);

    if (_type == TransactionType.income) {
      _selectedCategoryId = 'salary';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateSuggestedCategory() {
    final note = _noteController.text.toLowerCase();
    String? suggestion;

    if (note.contains('rent')) {
      suggestion = 'rent';
    } else if (note.contains('coffee') || note.contains('starbucks')) {
      suggestion = 'coffee';
    } else if (note.contains('salary') ||
        note.contains('pay') ||
        note.contains('income')) {
      suggestion = 'salary';
    } else if (note.contains('uber') ||
        note.contains('bus') ||
        note.contains('taxi')) {
      suggestion = 'transport';
    } else {
      suggestion = null;
    }

    if (suggestion != _suggestedCategoryId) {
      setState(() {
        _suggestedCategoryId = suggestion;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final trackingCubit = context.read<TrackingCubit>();
    final userId = trackingCubit.userId;

    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      amount: amount,
      date: _date,
      note: _noteController.text.isEmpty
          ? (_receiptAttached ? 'Receipt attached' : null)
          : _noteController.text,
      categoryId: _selectedCategoryId,
      type: _type,
    );

    await trackingCubit.addNewTransaction(tx);
    if (mounted) {
      widget.onClose?.call();
    }
  }

  void _applySuggestedCategory() {
    if (_suggestedCategoryId == null) return;

    if (_type == TransactionType.expense && _suggestedCategoryId == 'salary') {
      return;
    }

    setState(() {
      _selectedCategoryId = _suggestedCategoryId!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TransactionType.expense;

    final fieldTheme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BudgetaColors.background,
        labelStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 560),
      decoration: const BoxDecoration(
        color: BudgetaColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // grab handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // header row
            Row(
              children: [
                const Text(
                  'Add Transaction ✨',
                  style: TextStyle(
                    color: BudgetaColors.deep,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close_rounded),
                  color: BudgetaColors.deep,
                ),
              ],
            ),

            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Log today’s money move in seconds',
                style: TextStyle(
                  color: BudgetaColors.deep.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // card with form
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Theme(
                    data: fieldTheme,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          // segmented Expense / Income bar
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: BudgetaColors.backgroundLight,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                _TypeSegment(
                                  label: 'Expense',
                                  icon: Icons.trending_down_rounded,
                                  selected: isExpense,
                                  onTap: () {
                                    setState(() {
                                      _type = TransactionType.expense;
                                      if (_selectedCategoryId == 'salary') {
                                        _selectedCategoryId = 'food';
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(width: 6),
                                _TypeSegment(
                                  label: 'Income',
                                  icon: Icons.trending_up_rounded,
                                  selected: !isExpense,
                                  onTap: () {
                                    setState(() {
                                      _type = TransactionType.income;
                                      _selectedCategoryId = 'salary';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            'Amount',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: BudgetaColors.deep,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 6),

                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.attach_money_rounded),
                              hintText: '0.00',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter amount';
                              }
                              final parsed = double.tryParse(value);
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Category',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: BudgetaColors.deep,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 6),

                          CategoryChipList(
                            selectedCategoryId: _selectedCategoryId,
                            onCategorySelected: (id) {
                              if (id == null) return;
                              setState(() => _selectedCategoryId = id);
                            },
                            incomeOnly: _type == TransactionType.income,
                            hideIncomeInExpense:
                                _type == TransactionType.expense,
                            showAllChip: false,
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Description (Optional)',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: BudgetaColors.deep,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 6),

                          TextFormField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              hintText: "What's this for?",
                            ),
                          ),

                          if (_suggestedCategoryId != null) ...[
                            const SizedBox(height: 10),
                            _buildSmartCategorySuggestion(),
                          ],

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.calendar_month_rounded,
                                  ),
                                  title: const Text('Date'),
                                  subtitle: Text(
                                    _date.toLocal().toString().split(' ').first,
                                  ),
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _date,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() => _date = picked);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    _receiptAttached
                                        ? Icons.receipt_long_rounded
                                        : Icons.receipt_long_outlined,
                                    color: _receiptAttached
                                        ? BudgetaColors.primary
                                        : Colors.grey,
                                  ),
                                  title: const Text('Receipt'),
                                  subtitle: Text(
                                    _receiptAttached
                                        ? 'Attached'
                                        : 'Not attached',
                                    style: TextStyle(
                                      color: _receiptAttached
                                          ? BudgetaColors.primary
                                          : Colors.grey,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(
                                      () =>
                                          _receiptAttached = !_receiptAttached,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _receiptAttached
                                              ? 'Receipt marked as attached.'
                                              : 'Receipt removed.',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            height: 50,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF9A0E3A),
                                    Color(0xFFFF4F8B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextButton(
                                onPressed: _save,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  'Add Transaction 💕',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartCategorySuggestion() {
    final isExpense = _type == TransactionType.expense;

    if (isExpense && _suggestedCategoryId == 'salary') {
      return const SizedBox.shrink();
    }

    final displayName = _suggestedCategoryId!.toUpperCase();
    final isSelected = _selectedCategoryId == _suggestedCategoryId;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: BudgetaColors.accentLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Smart suggestion: $displayName',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: isSelected ? null : _applySuggestedCategory,
            child: Text(isSelected ? 'Applied' : 'Apply'),
          ),
        ],
      ),
    );
  }
}

class _TypeSegment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: selected
                ? BudgetaColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? BudgetaColors.deep
                    : BudgetaColors.deep.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? BudgetaColors.deep
                      : BudgetaColors.deep.withValues(alpha: 0.7),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
