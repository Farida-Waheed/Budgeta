import 'transaction_repo.dart';
import '../models/transaction.dart';

class DashboardRepository {
  final TransactionRepository transactionRepo;

  DashboardRepository(this.transactionRepo);

  double getMonthlyExpense() {
    final now = DateTime.now();
    return transactionRepo
        .getAll()
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double getMonthlyIncome() {
    final now = DateTime.now();
    return transactionRepo
        .getAll()
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0, (sum, item) => sum + item.amount);
  }

  Map<String, double> getCategoryBreakdown() {
    final map = <String, double>{};

    for (var t in transactionRepo.getAll()) {
      if (t.type == TransactionType.expense) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }
}
