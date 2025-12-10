// lib/features/tracking/state/tracking_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/transaction.dart';
import '../../../core/models/recurring_rule.dart';
import '../../../core/models/category_rule.dart';
import '../../../core/models/tracking_summary.dart';
import '../data/tracking_repository.dart';

part 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  final TrackingRepository repository;
  final String userId;

  TrackingCubit({required this.repository, required this.userId})
    : super(TrackingInitial());

  Future<void> loadTransactions() async {
    emit(TrackingLoading());
    try {
      final txs = await repository.getTransactions(userId: userId);
      final rules = await repository.getRecurringRules(userId);
      final catRules = await repository.getCategoryRules(userId);
      emit(
        TrackingLoaded(
          transactions: txs,
          recurringRules: rules,
          categoryRules: catRules,
        ),
      );
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  // ---------- Transactions ----------

  Future<void> addNewTransaction(Transaction transaction) async {
    try {
      await repository.addTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  Future<void> updateExistingTransaction(Transaction transaction) async {
    try {
      await repository.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  Future<void> deleteTransactionById(String id) async {
    try {
      await repository.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  // ---------- Recurring ----------

  Future<void> addNewRecurringRule(RecurringRule rule) async {
    try {
      await repository.addRecurringRule(rule);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  Future<void> updateExistingRecurringRule(RecurringRule rule) async {
    try {
      await repository.updateRecurringRule(rule);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  Future<void> toggleRecurringRule(String ruleId) async {
    try {
      await repository.pauseRecurringRule(ruleId);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  Future<void> deleteRecurringRule(String ruleId) async {
    try {
      await repository.deleteRecurringRule(ruleId);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  /// Run auto-posting of recurring rules up to "now".
  /// Returns the number of created transactions (for snackbar).
  Future<int> processRecurringForToday() async {
    try {
      final created = await repository.processRecurringRules(
        userId: userId,
        until: DateTime.now(),
      );
      await loadTransactions();
      return created;
    } catch (e) {
      emit(TrackingError(e.toString()));
      return 0;
    }
  }

  // ---------- Category rules (smart categories) ----------

  Future<void> addOrUpdateCategoryRule(CategoryRule rule) async {
    try {
      await repository.addOrUpdateCategoryRule(rule);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  Future<void> deleteCategoryRule(String ruleId) async {
    try {
      await repository.deleteCategoryRule(ruleId);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  // ---------- Summary / export / reset ----------

  Future<TrackingSummary> getSummary({DateTime? from, DateTime? to}) {
    return repository.getSummary(userId: userId, from: from, to: to);
  }

  Future<String> exportCsv({
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
  }) {
    return repository.exportTransactionsCsv(
      userId: userId,
      from: from,
      to: to,
      categoryId: categoryId,
      type: type,
    );
  }

  /// Remove all transactions + recurring rules + category rules
  /// for this user (clears demo data + anything the user added).
  Future<void> clearAllUserData() async {
    try {
      await repository.clearAllUserData(userId);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }
}
