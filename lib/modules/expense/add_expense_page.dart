import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../data/models/transaction.dart';
import 'expense_controller.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final amountController = TextEditingController();
  final categoryController = TextEditingController();
  final noteController = TextEditingController();

  // default type = Expense
  TransactionType selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ExpenseController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Transaction",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // -----------------------------
            //  Expense / Income toggle
            // -----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Expense"),
                  selected: selectedType == TransactionType.expense,
                  selectedColor: Colors.redAccent.withValues(alpha: 0.2),
                  onSelected: (_) {
                    setState(() => selectedType = TransactionType.expense);
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text("Income"),
                  selected: selectedType == TransactionType.income,
                  selectedColor: Colors.greenAccent.withValues(alpha: 0.2),
                  onSelected: (_) {
                    setState(() => selectedType = TransactionType.income);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // -----------------------------
            //  Input fields
            // -----------------------------
            AppTextField(
              label: "Amount",
              controller: amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: "Category",
              controller: categoryController,
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: "Note (optional)",
              controller: noteController,
            ),
            const SizedBox(height: 32),

            // -----------------------------
            //  Add button
            // -----------------------------
            AppButton(
              text: "Add",
              onPressed: () {
                final amount = double.tryParse(amountController.text);

                if (amount == null || categoryController.text.isEmpty) {
                  // you can add a SnackBar here later
                  return;
                }

                if (selectedType == TransactionType.expense) {
                  controller.addExpense(
                    amount: amount,
                    category: categoryController.text,
                    note: noteController.text,
                  );
                } else {
                  controller.addIncome(
                    amount: amount,
                    category: categoryController.text,
                    note: noteController.text,
                  );
                }

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
