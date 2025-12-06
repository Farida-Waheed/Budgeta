import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/transaction.dart';
import '../../state/tracking_cubit.dart';
import '../widgets/category_chip_list.dart';

/// Wrapper screen (used when pushing via route).
class AddTransactionScreen extends StatelessWidget {
  final TransactionType? preselectedType;

  const AddTransactionScreen({super.key, this.preselectedType});

  @override
  Widget build(BuildContext context) {
    final isExpense =
        (preselectedType ?? TransactionType.expense) == TransactionType.expense;

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
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

    if (_type == TransactionType.expense &&
        _suggestedCategoryId == 'salary') {
      return;
    }

    setState(() {
      _selectedCategoryId = _suggestedCategoryId!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TransactionType.expense;

    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isExpense
                      ? BudgetaColors.primary.withValues(alpha: 0.2)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isExpense ? 'Expense' : 'Income',
                  style: TextStyle(
                    color: isExpense
                        ? BudgetaColors.primary
                        : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              DropdownButton<TransactionType>(
                value: _type,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('Expense'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('Income'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _type = val;
                      if (val == TransactionType.income) {
                        _selectedCategoryId = 'salary';
                      } else {
                        if (_selectedCategoryId == 'salary') {
                          _selectedCategoryId = 'food';
                        }
                      }
                    });
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Amount
          TextFormField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixIcon: Icon(Icons.payments_outlined),
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

          const SizedBox(height: 16),

          // Note
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Description (e.g. coffee, rent...)',
              prefixIcon: Icon(Icons.edit_note_outlined),
            ),
          ),

          if (_suggestedCategoryId != null) ...[
            const SizedBox(height: 8),
            _buildSmartCategorySuggestion(),
          ],

          const SizedBox(height: 16),

          Text(
            'Category',
            style: Theme.of(context).textTheme.labelLarge,
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

          const SizedBox(height: 8),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              _receiptAttached
                  ? Icons.attachment
                  : Icons.attachment_outlined,
              color:
                  _receiptAttached ? BudgetaColors.primary : Colors.grey,
            ),
            title: const Text('Attach Receipt'),
            onTap: () {
              setState(() {
                _receiptAttached = !_receiptAttached;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_receiptAttached
                      ? 'Receipt marked as attached.'
                      : 'Receipt removed.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: BudgetaColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Add Transaction 💕'),
          ),
        ],
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
