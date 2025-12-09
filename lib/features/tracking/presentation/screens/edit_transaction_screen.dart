import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/transaction.dart';
import '../../state/tracking_cubit.dart';
import '../widgets/category_chip_list.dart';

class EditTransactionScreen extends StatelessWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.35),
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: EditTransactionSheetContent(
                transaction: transaction,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EditTransactionSheetContent extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback? onClose;

  const EditTransactionSheetContent({
    super.key,
    required this.transaction,
    this.onClose,
  });

  @override
  State<EditTransactionSheetContent> createState() =>
      _EditTransactionSheetContentState();
}

class _EditTransactionSheetContentState
    extends State<EditTransactionSheetContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _date;
  late TransactionType _type;
  late String _selectedCategoryId;

  String? _suggestedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _date = widget.transaction.date;
    _type = widget.transaction.type;
    _selectedCategoryId = widget.transaction.categoryId;

    _noteController.addListener(_updateSuggestedCategory);
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
      setState(() => _suggestedCategoryId = suggestion);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final trackingCubit = context.read<TrackingCubit>();

    final updated = Transaction(
      id: widget.transaction.id,
      userId: widget.transaction.userId,
      amount: amount,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      categoryId: _selectedCategoryId,
      type: _type,
      recurringRuleId: widget.transaction.recurringRuleId,
      isPartOfChallenge: widget.transaction.isPartOfChallenge,
    );

    await trackingCubit.updateExistingTransaction(updated);
    if (mounted) Navigator.pop(context);
  }

  void _applySuggestedCategory() {
    if (_suggestedCategoryId == null) return;
    setState(() => _selectedCategoryId = _suggestedCategoryId!);
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == TransactionType.expense;

    // same field theme as AddTransaction sheet
    final fieldTheme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFF1F5),
        labelStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );

    return Material(
      color: BudgetaColors.backgroundLight,
      borderRadius: BorderRadius.circular(32),
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // top handle
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              // header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Transaction ✨',
                            style: TextStyle(
                              color: BudgetaColors.deep,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fine-tune the details any time',
                            style: TextStyle(
                              color: BudgetaColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close_rounded),
                      color: BudgetaColors.deep,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // inner white card like Add sheet
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Theme(
                        data: fieldTheme,
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              // Expense / Income segmented control
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: BudgetaColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    _TypeSegmentEdit(
                                      label: 'Expense',
                                      selected: isExpense,
                                      onTap: () {
                                        setState(() {
                                          _type = TransactionType.expense;
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 6),
                                    _TypeSegmentEdit(
                                      label: 'Income',
                                      selected: !isExpense,
                                      onTap: () {
                                        setState(() {
                                          _type = TransactionType.income;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Amount label + field
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
                                keyboardType:
                                    const TextInputType.numberWithOptions(
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

                              // Note / description
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
                                  hintText: 'What\'s this for?',
                                  prefixIcon: Icon(Icons.edit_note_outlined),
                                ),
                              ),

                              const SizedBox(height: 10),

                              if (_suggestedCategoryId != null)
                                _buildSmartCategorySuggestion(),

                              const SizedBox(height: 18),

                              // Category chips
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
                              ),

                              const SizedBox(height: 18),

                              // Date row (kept same as before)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.calendar_today_outlined,
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

                              const SizedBox(height: 24),

                              SizedBox(
                                height: 50,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF9A0E3A),
                                        Color(0xFFFF4F8B),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
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
                                      'Save changes',
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
  }

  Widget _buildSmartCategorySuggestion() {
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

/// Helper to open as bottom-sheet over existing screen.
Future<void> showEditTransactionBottomSheet(
  BuildContext context, {
  required Transaction transaction,
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
          top: mq.size.height * 0.3,
        ),
        child: EditTransactionSheetContent(
          transaction: transaction,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      );
    },
  );
}

/// Local copy of the segmented control pill used for Expense / Income.
class _TypeSegmentEdit extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeSegmentEdit({
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
