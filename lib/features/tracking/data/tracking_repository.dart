import '../../../core/models/transaction.dart';
import '../../../core/models/recurring_rule.dart';

abstract class TrackingRepository {
  Future<List<Transaction>> getTransactions({
    required String userId,
    DateTime? from,
    DateTime? to,
  });

  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);

  Future<List<RecurringRule>> getRecurringRules(String userId);
  Future<void> addRecurringRule(RecurringRule rule);
  Future<void> pauseRecurringRule(String ruleId);
  Future<void> deleteRecurringRule(String ruleId);

  /// Clear all transactions + recurring rules for this user.
  /// Used to remove dummy examples and user data.
  Future<void> clearAllUserData(String userId);
}
