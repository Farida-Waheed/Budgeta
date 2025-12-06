// lib/features/tracking/data/in_memory_tracking_repository.dart

import '../../../core/models/transaction.dart';
import '../../../core/models/recurring_rule.dart';
import 'tracking_repository.dart';

/// High-level repository used by the Cubit.
/// For now it keeps everything in memory per user.
class InMemoryTrackingRepository implements TrackingRepository {
  // ---------- SINGLETON PATTERN ----------
  // Every time you call InMemoryTrackingRepository(), you get this same instance.
  InMemoryTrackingRepository._internal();
  static final InMemoryTrackingRepository _instance =
      InMemoryTrackingRepository._internal();
  factory InMemoryTrackingRepository() => _instance;

  // ---------- INTERNAL STATE ----------
  final Map<String, List<Transaction>> _transactionsByUser = {};
  final Map<String, List<RecurringRule>> _rulesByUser = {};

  List<Transaction> _txList(String userId) =>
      _transactionsByUser.putIfAbsent(userId, () => []);

  List<RecurringRule> _ruleList(String userId) =>
      _rulesByUser.putIfAbsent(userId, () => []);

  // ---------- TRANSACTIONS ----------

  @override
  Future<List<Transaction>> getTransactions({
    required String userId,
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
  }) async {
    var list = List<Transaction>.from(_txList(userId));

    if (from != null) {
      list = list.where((t) => !t.date.isBefore(from)).toList();
    }
    if (to != null) {
      list = list.where((t) => !t.date.isAfter(to)).toList();
    }
    if (categoryId != null) {
      list = list.where((t) => t.categoryId == categoryId).toList();
    }
    if (type != null) {
      list = list.where((t) => t.type == type).toList();
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _txList(transaction.userId).add(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final list = _txList(transaction.userId);
    final index = list.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      list[index] = transaction;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    for (final entry in _transactionsByUser.entries) {
      entry.value.removeWhere((t) => t.id == id);
    }
  }

  // ---------- RECURRING RULES ----------

  @override
  Future<List<RecurringRule>> getRecurringRules(String userId) async {
    return List<RecurringRule>.from(_ruleList(userId));
  }

  @override
  Future<void> addRecurringRule(RecurringRule rule) async {
    _ruleList(rule.userId).add(rule);
  }

  @override
  Future<void> pauseRecurringRule(String ruleId) async {
    for (final entry in _rulesByUser.entries) {
      final list = entry.value;
      final index = list.indexWhere((r) => r.id == ruleId);
      if (index != -1) {
        final old = list[index];
        list[index] = RecurringRule(
          id: old.id,
          userId: old.userId,
          amount: old.amount,
          startDate: old.startDate,
          endDate: old.endDate,
          frequency: old.frequency,
          categoryId: old.categoryId,
          isActive: !old.isActive,
        );
        break;
      }
    }
  }

  @override
  Future<void> deleteRecurringRule(String ruleId) async {
    for (final entry in _rulesByUser.entries) {
      entry.value.removeWhere((r) => r.id == ruleId);
    }
  }

  @override
  Future<void> clearAllUserData(String userId) async {
    _transactionsByUser.remove(userId);
    _rulesByUser.remove(userId);
  }
}
