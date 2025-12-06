// lib/features/tracking/state/tracking_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/transaction.dart';
import '../../../core/models/recurring_rule.dart';
import '../data/tracking_repository.dart';

part 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  final TrackingRepository repository;
  final String userId;

  TrackingCubit({
    required this.repository,
    required this.userId,
  }) : super(TrackingInitial());

  Future<void> loadTransactions() async {
    emit(TrackingLoading());
    try {
      final txs = await repository.getTransactions(userId: userId);
      final rules = await repository.getRecurringRules(userId);
      emit(TrackingLoaded(transactions: txs, recurringRules: rules));
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

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

  Future<void> addNewRecurringRule(RecurringRule rule) async {
    try {
      await repository.addRecurringRule(rule);
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

  /// Remove all transactions + recurring rules for this user
  /// (clears demo data + anything the user added).
  Future<void> clearAllUserData() async {
    try {
      await repository.clearAllUserData(userId);
      await loadTransactions();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }
}
