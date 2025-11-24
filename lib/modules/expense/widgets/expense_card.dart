import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final String title;
  final double amount;

  const ExpenseCard({super.key, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text("\$${amount.toStringAsFixed(2)}"),
    );
  }
}
