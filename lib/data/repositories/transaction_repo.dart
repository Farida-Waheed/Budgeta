import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final List<TransactionModel> _transactions = [];
  final uuid = const Uuid();

  List<TransactionModel> getAll() {
    return _transactions;
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
  }

  void add({
    required double amount,
    required String category,
    required TransactionType type,
    String? note,
    String? receipt,
  }) {
    _transactions.add(
      TransactionModel(
        id: uuid.v4(),
        amount: amount,
        category: category,
        date: DateTime.now(),
        type: type,
        note: note,
        receiptImage: receipt,
      ),
    );
  }

  void delete(String id) {
    _transactions.removeWhere((t) => t.id == id);
  }

  double getTotalExpenses() {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, item) => sum + item.amount);
  }
}
