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
      backgroundColor: BudgetaColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
    _noteController =
        TextEditingController(text: widget.transaction.note ?? '');
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

    final fieldTheme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );

    return Material(
      color: BudgetaColors.backgroundLight,
      borderRadius: BorderRadius.circular(32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
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
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F5),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE4ED),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isExpense
                                            ? Icons.trending_down_rounded
                                            : Icons.trending_up_rounded,
                                        size: 16,
                                        color: isExpense
                                            ? BudgetaColors.primary
                                            : Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isExpense ? 'Expense' : 'Income',
                                        style: TextStyle(
                                          color: isExpense
                                              ? BudgetaColors.primary
                                              : Colors.green.shade700,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
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
                                      setState(() => _type = val);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Amount
                            TextFormField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                prefixIcon:
                                    Icon(Icons.attach_money_rounded),
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

                            // Note
                            TextFormField(
                              controller: _noteController,
                              decoration: const InputDecoration(
                                labelText: 'Note',
                                prefixIcon:
                                    Icon(Icons.edit_note_outlined),
                              ),
                            ),
                            const SizedBox(height: 10),

                            if (_suggestedCategoryId != null)
                              _buildSmartCategorySuggestion(),
                            const SizedBox(height: 18),

                            // Category
                            Text(
                              'Category',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
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

                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading:
                                  const Icon(Icons.calendar_today_outlined),
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
                                      Color(0xFFFF4F8B)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TextButton(
                                  onPressed: _save,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(24),
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
          top: mq.size.height * 0.25,
        ),
        child: EditTransactionSheetContent(
          transaction: transaction,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      );
    },
  );
}
