// lib/features/tracking/data/tracking_remote_ds.dart

import '../../../core/models/transaction.dart';
import '../../../core/models/recurring_rule.dart';

/// Abstraction for any remote API (REST, GraphQL, etc.)
abstract class TrackingRemoteDataSource {
  Future<void> syncTransactions(List<Transaction> transactions);
  Future<void> syncRecurringRules(List<RecurringRule> rules);

  // Later: load from server if needed
  // Future<List<Transaction>> fetchTransactionsFromServer(String userId);
}

/// Dummy implementation for now.
/// You can replace this later with real HTTP calls.
class DummyTrackingRemoteDataSource implements TrackingRemoteDataSource {
  @override
  Future<void> syncTransactions(List<Transaction> transactions) async {
    // no-op for now
  }

  @override
  Future<void> syncRecurringRules(List<RecurringRule> rules) async {
    // no-op for now
  }
}
