// lib/features/tracking/data/tracking_repository.dart

import '../../../core/models/transaction.dart';
import '../../../core/models/recurring_rule.dart';
import '../../../core/models/category.dart';
import '../../../core/models/tracking_summary.dart';

/// Core abstraction for the Tracking subsystem.
/// Defines ALL use cases required by:
/// - Expense & Income Tracking
/// - Recurring Scheduling
/// - Dashboard summarization
/// - Coach insights
/// - Challenges (optional flag inside Transaction)
/// - Category rules for smart suggestions
/// - Export / admin review
abstract class TrackingRepository {
  /// -------------------------------
  /// GET TRANSACTIONS (with filters)
  /// -------------------------------
  Future<List<Transaction>> getTransactions({
    required String userId,
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
  });

  /// A higher-level summary for dashboards / coach.
  Future<TrackingSummary> getSummary({
    required String userId,
    DateTime? from,
    DateTime? to,
  });

  /// Export filtered transactions as CSV text (for sharing / auditing).
  Future<String> exportTransactionsCsv({
    required String userId,
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
  });

  /// -------------------------------
  /// CRUD: TRANSACTIONS
  /// -------------------------------
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);

  /// -------------------------------
  /// RECURRING RULES
  /// -------------------------------
  Future<List<RecurringRule>> getRecurringRules(String userId);

  /// Create a new recurring rule (rent, salary, subscription, etc.).
  Future<void> addRecurringRule(RecurringRule rule);

  /// Edit an existing recurring rule (change amount, frequency, category).
  Future<void> updateRecurringRule(RecurringRule rule);

  /// Pause / resume a rule without deleting it.
  Future<void> pauseRecurringRule(String ruleId);

  /// Delete a recurring rule completely.
  Future<void> deleteRecurringRule(String ruleId);

  /// Run automatic posting for all due rules up to [until].
  /// Returns how many transactions were created.
  Future<int> processRecurringRules({required String userId, DateTime? until});

  /// Optional: list rules that are due before [until] (for Coach reminders).
  Future<List<RecurringRule>> getUpcomingRecurringRules({
    required String userId,
    required DateTime until,
  });

  /// -------------------------------
  /// CATEGORY RULES (Smart categories)
  /// -------------------------------
  Future<List<CategoryRule>> getCategoryRules(String userId);
  Future<void> addOrUpdateCategoryRule(CategoryRule rule);
  Future<void> deleteCategoryRule(String ruleId);

  /// -------------------------------
  /// CLEAR ALL DATA
  /// For demos, resetting UI, onboarding flows, tests, etc.
  /// -------------------------------
  Future<void> clearAllUserData(String userId);
}
