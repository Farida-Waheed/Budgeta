// lib/features/tracking/data/in_memory_tracking_repository.dart
import '../../../core/models/transaction.dart';
import '../../../core/models/recurring_rule.dart';
import '../../../core/models/category_rule.dart';
import '../../../core/models/tracking_summary.dart';
import 'tracking_repository.dart';

/// High-level repository used by the Cubit.
/// For now it keeps everything in memory per user.
class InMemoryTrackingRepository implements TrackingRepository {
  // ---------- SINGLETON PATTERN ----------
  InMemoryTrackingRepository._internal();
  static final InMemoryTrackingRepository _instance =
      InMemoryTrackingRepository._internal();
  factory InMemoryTrackingRepository() => _instance;

  // ---------- INTERNAL STATE ----------
  final Map<String, List<Transaction>> _transactionsByUser = {};
  final Map<String, List<RecurringRule>> _rulesByUser = {};
  final Map<String, List<CategoryRule>> _categoryRulesByUser = {};

  List<Transaction> _txList(String userId) =>
      _transactionsByUser.putIfAbsent(userId, () => []);

  List<RecurringRule> _ruleList(String userId) =>
      _rulesByUser.putIfAbsent(userId, () => []);

  List<CategoryRule> _categoryRuleList(String userId) => _categoryRulesByUser
      .putIfAbsent(userId, () => _defaultCategoryRules(userId));

  List<CategoryRule> _defaultCategoryRules(String userId) {
    // basic demo rules, can be edited via UI
    return [
      CategoryRule(
        id: 'cr_rent_$userId',
        userId: userId,
        pattern: 'rent',
        categoryId: 'rent',
      ),
      CategoryRule(
        id: 'cr_coffee_$userId',
        userId: userId,
        pattern: 'coffee',
        categoryId: 'coffee',
      ),
      CategoryRule(
        id: 'cr_salary_$userId',
        userId: userId,
        pattern: 'salary',
        categoryId: 'salary',
      ),
      CategoryRule(
        id: 'cr_uber_$userId',
        userId: userId,
        pattern: 'uber',
        categoryId: 'transport',
      ),
    ];
  }

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

  // ---------- SUMMARY / EXPORT ----------

  @override
  Future<TrackingSummary> getSummary({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    final txs = await getTransactions(userId: userId, from: from, to: to);

    double income = 0;
    double expense = 0;
    final perCat = <String, double>{};

    for (final t in txs) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
      perCat[t.categoryId] = (perCat[t.categoryId] ?? 0) + t.amount;
    }

    return TrackingSummary(
      totalIncome: income,
      totalExpense: expense,
      perCategoryTotals: perCat,
      transactionCount: txs.length,
    );
  }

  @override
  Future<String> exportTransactionsCsv({
    required String userId,
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
  }) async {
    final txs = await getTransactions(
      userId: userId,
      from: from,
      to: to,
      categoryId: categoryId,
      type: type,
    );

    final buffer = StringBuffer();
    buffer.writeln(
      'id,userId,date,type,amount,categoryId,note,recurringRuleId,isPartOfChallenge,receiptImagePath',
    );

    for (final t in txs) {
      final typeStr = t.type == TransactionType.expense ? 'expense' : 'income';
      final dateStr = t.date.toIso8601String();
      final noteEscaped = (t.note ?? '').replaceAll('"', '""');
      final recId = t.recurringRuleId ?? '';
      final recFlag = t.isPartOfChallenge ? 'true' : 'false';
      final receipt = t.receiptImagePath ?? '';

      buffer.writeln(
        '"${t.id}","${t.userId}","$dateStr","$typeStr",'
        '${t.amount},"${t.categoryId}","$noteEscaped","$recId","$recFlag","$receipt"',
      );
    }

    return buffer.toString();
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
  Future<void> updateRecurringRule(RecurringRule rule) async {
    final list = _ruleList(rule.userId);
    final index = list.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      list[index] = rule;
    }
  }

  @override
  Future<void> pauseRecurringRule(String ruleId) async {
    for (final entry in _rulesByUser.entries) {
      final list = entry.value;
      final index = list.indexWhere((r) => r.id == ruleId);
      if (index != -1) {
        final old = list[index];
        list[index] = old.copyWith(isActive: !old.isActive);
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
  Future<int> processRecurringRules({
    required String userId,
    DateTime? until,
  }) async {
    final now = until ?? DateTime.now();
    final rules = _ruleList(userId);
    final txList = _txList(userId);
    int createdCount = 0;

    for (var i = 0; i < rules.length; i++) {
      var rule = rules[i];
      if (!rule.isActive) continue;

      final end = rule.endDate;
      if (end != null && end.isBefore(now)) continue;

      DateTime nextDue = rule.nextDueDate ?? rule.startDate;
      bool changed = false;

      while (!nextDue.isAfter(now)) {
        // create transaction
        final id = 'auto_${rule.id}_${nextDue.millisecondsSinceEpoch}';
        final isIncomeLike = rule.categoryId == 'salary';

        txList.add(
          Transaction(
            id: id,
            userId: rule.userId,
            amount: rule.amount,
            date: nextDue,
            categoryId: rule.categoryId,
            type: isIncomeLike
                ? TransactionType.income
                : TransactionType.expense,
            note: 'Auto from recurring (${rule.categoryId})',
            recurringRuleId: rule.id,
          ),
        );
        createdCount++;

        // advance nextDue
        nextDue = _advanceDate(nextDue, rule.frequency);
        changed = true;
        if (end != null && nextDue.isAfter(end)) break;
      }

      if (changed) {
        rules[i] = rule.copyWith(nextDueDate: nextDue);
      }
    }

    return createdCount;
  }

  @override
  Future<List<RecurringRule>> getUpcomingRecurringRules({
    required String userId,
    required DateTime until,
  }) async {
    final rules = _ruleList(userId);
    final result = <RecurringRule>[];

    for (final r in rules) {
      if (!r.isActive) continue;
      final end = r.endDate;
      if (end != null && end.isBefore(DateTime.now())) continue;

      final next = r.nextDueDate ?? r.startDate;
      if (!next.isAfter(until)) {
        result.add(r);
      }
    }

    return result;
  }

  DateTime _advanceDate(DateTime date, RecurringFrequency f) {
    switch (f) {
      case RecurringFrequency.daily:
        return date.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return date.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(date.year, date.month + 1, date.day);
      case RecurringFrequency.yearly:
        return DateTime(date.year + 1, date.month, date.day);
    }
  }

  // ---------- CATEGORY RULES ----------

  @override
  Future<List<CategoryRule>> getCategoryRules(String userId) async {
    return List<CategoryRule>.from(_categoryRuleList(userId));
  }

  @override
  Future<void> addOrUpdateCategoryRule(CategoryRule rule) async {
    final list = _categoryRuleList(rule.userId);
    final index = list.indexWhere((r) => r.id == rule.id);
    if (index == -1) {
      list.add(rule);
    } else {
      list[index] = rule;
    }
  }

  @override
  Future<void> deleteCategoryRule(String ruleId) async {
    for (final entry in _categoryRulesByUser.entries) {
      entry.value.removeWhere((r) => r.id == ruleId);
    }
  }

  // ---------- CLEAR ALL ----------

  @override
  Future<void> clearAllUserData(String userId) async {
    _transactionsByUser.remove(userId);
    _rulesByUser.remove(userId);
    _categoryRulesByUser.remove(userId);
  }
}
