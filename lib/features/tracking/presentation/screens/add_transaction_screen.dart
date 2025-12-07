// lib/features/tracking/presentation/screens/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/transaction.dart';
import '../../state/tracking_cubit.dart';
import '../widgets/category_chip_list.dart';

/// Wrapper screen (can still be used as a full page route if you want).
class AddTransactionScreen extends StatelessWidget {
  final TransactionType? preselectedType;

  const AddTransactionScreen({super.key, this.preselectedType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Transaction ✨',
          style: TextStyle(color: BudgetaColors.deep),
        ),
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: AddTransactionForm(preselectedType: preselectedType),
          ),
        ),
      ),
    );
  }
}

/// Reusable form widget (used in full screen & bottom sheet)
class AddTransactionForm extends StatefulWidget {
  final TransactionType? preselectedType;

  const AddTransactionForm({super.key, this.preselectedType});

  @override
  State<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
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
    if (mounted) Navigator.pop(context);
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

    // softer fields like in the mockup
    final fieldTheme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BudgetaColors.background,
        labelStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );

    return Theme(
      data: fieldTheme,
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            // segmented Expense / Income bar (top of sheet)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: BudgetaColors.background,
                borderRadius: BorderRadius.circular(18),
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
                  const SizedBox(width: 8),
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

            const SizedBox(height: 20),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            // Note / Description
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: "What's this for?",
              ),
            ),

            if (_suggestedCategoryId != null) ...[
              const SizedBox(height: 8),
              _buildSmartCategorySuggestion(),
            ],

            const SizedBox(height: 16),

            Text(
              'Category',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),

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

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
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

            const SizedBox(height: 4),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _receiptAttached
                    ? Icons.attachment
                    : Icons.attachment_outlined,
                color: _receiptAttached ? BudgetaColors.primary : Colors.grey,
              ),
              title: const Text('Attach Receipt'),
              onTap: () {
                setState(() {
                  _receiptAttached = !_receiptAttached;
                });
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

            const SizedBox(height: 20),

            // Gradient-style big button like mockup
            SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      BudgetaColors.deep,
                      BudgetaColors.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextButton(
                  onPressed: _save,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Add Transaction 💕',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? BudgetaColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// =====================================================================
/// Bottom-sheet version: slide from bottom to top like the mockup
/// =====================================================================
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
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: mq.size.height * 0.78,
            decoration: BoxDecoration(
              color: BudgetaColors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 8),
                // small drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
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
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: BudgetaColors.deep,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: AddTransactionForm(
                          preselectedType: preselectedType,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
