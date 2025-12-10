// lib/features/tracking/presentation/screens/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/transaction.dart';
import '../../../../core/widgets/text_field.dart'; // MagicTextField
import '../../../../core/widgets/primary_button.dart';
import '../../state/tracking_cubit.dart';
import '../widgets/category_chip_list.dart';

/// Full-screen overlay that shows the card-style sheet at the bottom,
/// same feeling as "Create Goal ✨".
class AddTransactionScreen extends StatelessWidget {
  final TransactionType? preselectedType;

  const AddTransactionScreen({super.key, this.preselectedType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.35),
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AddTransactionSheetContent(
              preselectedType: preselectedType,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }
}

/// The rounded white card (same vibe as Create Goal ✨).
class AddTransactionSheetContent extends StatelessWidget {
  final TransactionType? preselectedType;
  final VoidCallback? onClose;

  const AddTransactionSheetContent({
    super.key,
    this.preselectedType,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 10,
      borderRadius: BorderRadius.circular(32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row (like Create Goal ✨)
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Transaction ✨',
                      style: TextStyle(
                        color: BudgetaColors.deep,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    color: BudgetaColors.deep,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AddTransactionForm(preselectedType: preselectedType),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddTransactionForm extends StatefulWidget {
  final TransactionType? preselectedType;

  const AddTransactionForm({super.key, this.preselectedType});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _date = DateTime.now();
  late TransactionType _type;
  String _selectedCategoryId = 'food';

  String? _suggestedCategoryId;
  bool _receiptAttached = false;
  String? _receiptImagePath;

  bool _isPartOfChallenge = false;

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

    final state = context.read<TrackingCubit>().state;
    if (state is TrackingLoaded) {
      for (final rule in state.categoryRules) {
        if (!rule.isActive) continue;
        if (note.contains(rule.pattern.toLowerCase())) {
          suggestion = rule.categoryId;
          break;
        }
      }
    }

    if (suggestion != _suggestedCategoryId) {
      setState(() => _suggestedCategoryId = suggestion);
    }
  }

  Future<void> _save() async {
    final rawAmount = _amountController.text.trim();
    final amount = double.tryParse(rawAmount) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

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
      receiptImagePath: _receiptImagePath,
      isPartOfChallenge: _isPartOfChallenge,
    );

    await trackingCubit.addNewTransaction(tx);
    if (mounted) Navigator.pop(context);
  }

  void _applySuggestedCategory() {
    if (_suggestedCategoryId == null) return;
    if (_type == TransactionType.expense && _suggestedCategoryId == 'salary') {
      return;
    }
    setState(() => _selectedCategoryId = _suggestedCategoryId!);
  }

  void _toggleReceipt() {
    setState(() {
      _receiptAttached = !_receiptAttached;
      if (_receiptAttached) {
        _receiptImagePath =
            'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else {
        _receiptImagePath = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _receiptAttached ? 'Receipt marked as attached.' : 'Receipt removed.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TransactionType.expense;

    return ListView(
      shrinkWrap: true,
      children: [
        // Type toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: BudgetaColors.backgroundLight,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              _TypeSegment(
                label: 'Expense',
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

        // Amount (MagicTextField for same look as Create Goal)
        MagicTextField(
          label: 'Amount',
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),

        const SizedBox(height: 14),

        // Category
        Text(
          'Category',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
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
          hideIncomeInExpense: _type == TransactionType.expense,
          showAllChip: false,
        ),

        const SizedBox(height: 16),

        // Description
        MagicTextField(
          label: 'Description (Optional)',
          controller: _noteController,
        ),

        if (_suggestedCategoryId != null) ...[
          const SizedBox(height: 8),
          _buildSmartCategorySuggestion(),
        ],

        const SizedBox(height: 18),

        // Date & Receipt row (same line but inside the card)
        Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_rounded),
                title: const Text('Date'),
                subtitle: Text(_date.toLocal().toString().split(' ').first),
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
                  color: _receiptAttached ? BudgetaColors.primary : Colors.grey,
                ),
                title: const Text('Receipt'),
                subtitle: Text(
                  _receiptAttached ? 'Attached' : 'Not attached',
                  style: TextStyle(
                    color: _receiptAttached
                        ? BudgetaColors.primary
                        : Colors.grey,
                  ),
                ),
                onTap: _toggleReceipt,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Part of challenge toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Part of a savings challenge?'),
          subtitle: const Text(
            'Toggle this if this transaction belongs to a challenge.',
            style: TextStyle(fontSize: 12),
          ),
          value: _isPartOfChallenge,
          activeThumbColor: BudgetaColors.primary,
          onChanged: (val) => setState(() => _isPartOfChallenge = val),
        ),

        const SizedBox(height: 16),

        // Primary gradient button (same style as Create Goal)
        PrimaryButton(label: 'Add Transaction 💕', onPressed: _save),
      ],
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
  final bool selected;
  final VoidCallback onTap;

  const _TypeSegment({
    required this.label,
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
            color: selected ? BudgetaColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? BudgetaColors.primary
                  : BudgetaColors.accentLight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : BudgetaColors.deep,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper used from other screens (Transactions list, etc.)
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
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: mq.viewInsets.bottom + 8,
          top: mq.size.height * 0.25,
        ),
        child: AddTransactionSheetContent(
          preselectedType: preselectedType,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      );
    },
  );
}
