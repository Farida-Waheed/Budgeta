// lib/features/tracking/data/tracking_repository.dart

import '../../../core/models/transaction.dart';
import '../../../core/models/recurring_rule.dart';

/// Core abstraction for the Tracking subsystem.
/// Defines ALL use cases required by:
/// - Expense & Income Tracking
/// - Recurring Scheduling
/// - Dashboard summarization
/// - Coach insights
/// - Challenges (optional flag inside Transaction)
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
  Future<void> addRecurringRule(RecurringRule rule);
  Future<void> pauseRecurringRule(String ruleId);
  Future<void> deleteRecurringRule(String ruleId);

  /// -------------------------------
  /// CLEAR ALL DATA
  /// For demos, resetting UI, onboarding flows, tests, etc.
  /// -------------------------------
  Future<void> clearAllUserData(String userId);
}
