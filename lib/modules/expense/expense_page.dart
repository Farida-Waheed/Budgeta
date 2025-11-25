import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/colors.dart';
import '../../data/models/transaction.dart';
import 'expense_controller.dart';
import 'add_expense_page.dart';

class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ExpenseController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Expenses",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.red,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpensePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: controller.transactions.map((t) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              title: Text(
                t.category,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(t.note ?? "-"),
              trailing: Text(
                "${t.type == TransactionType.expense ? '-' : '+'}${t.amount}",
                style: TextStyle(
                  color: t.type == TransactionType.expense
                      ? AppColors.red
                      : AppColors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
