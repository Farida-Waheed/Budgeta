import 'package:flutter/material.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repo.dart';

class ExpenseController extends ChangeNotifier {
  final TransactionRepository repo;

  ExpenseController(this.repo);

  List<TransactionModel> get transactions => repo.getAll();

  double get totalExpenses => repo.getTotalExpenses();
  double get totalIncome => repo.getTotalIncome();

  void addExpense({
    required double amount,
    required String category,
    String? note,
  }) {
    repo.add(
      amount: amount,
      category: category,
      type: TransactionType.expense,
      note: note,
    );
    notifyListeners();
  }

  void addIncome({
    required double amount,
    required String category,
    String? note,
  }) {
    repo.add(
      amount: amount,
      category: category,
      type: TransactionType.income,
      note: note,
    );
    notifyListeners();
  }

  void delete(String id) {
    repo.delete(id);
    notifyListeners();
  }
}
