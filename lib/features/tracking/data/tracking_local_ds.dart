// lib/features/tracking/data/tracking_local_ds.dart
import '../../../core/models/transaction.dart';
import '../../../core/models/recurring_rule.dart';

/// Abstraction for local storage (DB, SharedPreferences, etc.)
abstract class TrackingLocalDataSource {
  Future<Transaction> addTransaction(Transaction transaction);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String transactionId);

  Future<List<Transaction>> getTransactions({
    required String userId,
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
  });

  Future<List<RecurringRule>> getRecurringRules(String userId);
  Future<RecurringRule> addRecurringRule(RecurringRule rule);
  Future<RecurringRule> updateRecurringRule(RecurringRule rule);
  Future<void> toggleRecurringRuleActive(String ruleId);
}

/// Simple in-memory implementation for now.
/// Later you can replace this with Hive/SQLite/shared_prefs etc.
class InMemoryTrackingLocalDataSource implements TrackingLocalDataSource {
  final List<Transaction> _transactions = [];
  final List<RecurringRule> _recurringRules = [];

  InMemoryTrackingLocalDataSource() {
    final now = DateTime.now();

    // Demo transactions for the report / dashboard use cases
    _transactions.addAll([
      Transaction(
        id: 't1',
        userId: 'demo-user',
        amount: 120.0,
        date: now.subtract(const Duration(days: 2)),
        note: 'Groceries',
        categoryId: 'food',
        type: TransactionType.expense,
      ),
      Transaction(
        id: 't2',
        userId: 'demo-user',
        amount: 50.0,
        date: now.subtract(const Duration(days: 1)),
        note: 'Coffee with friends',
        categoryId: 'coffee',
        type: TransactionType.expense,
      ),
      Transaction(
        id: 't3',
        userId: 'demo-user',
        amount: 3000.0,
        date: now.subtract(const Duration(days: 5)),
        note: 'Part-time salary',
        categoryId: 'salary',
        type: TransactionType.income,
      ),
    ]);

    // Demo recurring rule for "fixed payments" use case
    _recurringRules.add(
      RecurringRule(
        id: 'r1',
        userId: 'demo-user',
        amount: 800.0,
        startDate: DateTime(now.year, now.month, 1),
        frequency: RecurringFrequency.monthly,
        categoryId: 'rent',
      ),
    );
  }

  // ---------------- TRANSACTIONS ----------------

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    _transactions.removeWhere((t) => t.id == transactionId);
  }

  @override
  Future<List<Transaction>> getTransactions({
    required String userId,
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
  }) async {
    return _transactions.where((t) {
      if (t.userId != userId) return false;
      if (from != null && t.date.isBefore(from)) return false;
      if (to != null && t.date.isAfter(to)) return false;
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (type != null && t.type != type) return false;
      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  // ---------------- RECURRING RULES ----------------

  @override
  Future<List<RecurringRule>> getRecurringRules(String userId) async {
    return _recurringRules.where((r) => r.userId == userId).toList();
  }

  @override
  Future<RecurringRule> addRecurringRule(RecurringRule rule) async {
    _recurringRules.add(rule);
    return rule;
  }

  @override
  Future<RecurringRule> updateRecurringRule(RecurringRule rule) async {
    final index = _recurringRules.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      _recurringRules[index] = rule;
    }
    return rule;
  }

  @override
  Future<void> toggleRecurringRuleActive(String ruleId) async {
    final index = _recurringRules.indexWhere((r) => r.id == ruleId);
    if (index != -1) {
      final old = _recurringRules[index];
      _recurringRules[index] = RecurringRule(
        id: old.id,
        userId: old.userId,
        amount: old.amount,
        startDate: old.startDate,
        endDate: old.endDate,
        frequency: old.frequency,
        categoryId: old.categoryId,
        isActive: !old.isActive,
      );
    }
  }
}
