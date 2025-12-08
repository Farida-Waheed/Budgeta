import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/transaction.dart';
import '../../state/tracking_cubit.dart';
import '../widgets/category_chip_list.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
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
      setState(() {
        _suggestedCategoryId = suggestion;
      });
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.35),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 560),
                  decoration: const BoxDecoration(
                    color: BudgetaColors.backgroundLight,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(18, 10, 18, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Edit Transaction ✨',
                              style: TextStyle(
                                color: BudgetaColors.deep,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                              color: BudgetaColors.deep,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Fine-tune the details any time',
                            style: TextStyle(
                              color: BudgetaColors.deep
                                  .withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Theme(
                                data: fieldTheme,
                                child: Form(
                                  key: _formKey,
                                  child: ListView(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isExpense
                                                  ? BudgetaColors
                                                      .primary
                                                      .withValues(
                                                          alpha:
                                                              0.12)
                                                  : Colors.green
                                                      .withOpacity(
                                                          0.12),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(24),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isExpense
                                                      ? Icons
                                                          .trending_down_rounded
                                                      : Icons
                                                          .trending_up_rounded,
                                                  size: 16,
                                                  color: isExpense
                                                      ? BudgetaColors
                                                          .primary
                                                      : Colors.green
                                                          .shade700,
                                                ),
                                                const SizedBox(
                                                    width: 6),
                                                Text(
                                                  isExpense
                                                      ? 'Expense'
                                                      : 'Income',
                                                  style: TextStyle(
                                                    color: isExpense
                                                        ? BudgetaColors
                                                            .primary
                                                        : Colors
                                                            .green
                                                            .shade700,
                                                    fontWeight:
                                                        FontWeight
                                                            .w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          DropdownButton<
                                              TransactionType>(
                                            value: _type,
                                            underline:
                                                const SizedBox
                                                    .shrink(),
                                            items: const [
                                              DropdownMenuItem(
                                                value: TransactionType
                                                    .expense,
                                                child:
                                                    Text('Expense'),
                                              ),
                                              DropdownMenuItem(
                                                value: TransactionType
                                                    .income,
                                                child:
                                                    Text('Income'),
                                              ),
                                            ],
                                            onChanged: (val) {
                                              if (val != null) {
                                                setState(() {
                                                  _type = val;
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        controller:
                                            _amountController,
                                        keyboardType:
                                            const TextInputType
                                                    .numberWithOptions(
                                                decimal: true),
                                        decoration:
                                            const InputDecoration(
                                          labelText: 'Amount',
                                          prefixIcon: Icon(Icons
                                              .attach_money_rounded),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.isEmpty) {
                                            return 'Enter amount';
                                          }
                                          final parsed =
                                              double.tryParse(
                                                  value);
                                          if (parsed == null ||
                                              parsed <= 0) {
                                            return 'Enter a valid amount';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller:
                                            _noteController,
                                        decoration:
                                            const InputDecoration(
                                          labelText: 'Note',
                                          prefixIcon: Icon(Icons
                                              .edit_note_outlined),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (_suggestedCategoryId !=
                                          null)
                                        _buildSmartCategorySuggestion(),
                                      const SizedBox(height: 18),
                                      Text(
                                        'Category',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color:
                                                  BudgetaColors.deep,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      CategoryChipList(
                                        selectedCategoryId:
                                            _selectedCategoryId,
                                        onCategorySelected: (id) {
                                          if (id == null) return;
                                          setState(() {
                                            _selectedCategoryId =
                                                id;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.zero,
                                        leading: const Icon(Icons
                                            .calendar_today_outlined),
                                        title:
                                            const Text('Date'),
                                        subtitle: Text(
                                          _date
                                              .toLocal()
                                              .toString()
                                              .split(' ')
                                              .first,
                                        ),
                                        onTap: () async {
                                          final picked =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: _date,
                                            firstDate:
                                                DateTime(2020),
                                            lastDate:
                                                DateTime(2100),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              _date = picked;
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        height: 48,
                                        child: ElevatedButton(
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                                BudgetaColors
                                                    .primary,
                                            foregroundColor:
                                                Colors.white,
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          22),
                                            ),
                                          ),
                                          onPressed: _save,
                                          child: const Text(
                                            'Save changes',
                                            style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .w600),
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
    final isSelected =
        _selectedCategoryId == _suggestedCategoryId;

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
