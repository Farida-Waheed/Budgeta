// lib/features/tracking/state/tracking_state.dart
part of 'tracking_cubit.dart';

abstract class TrackingState {}

class TrackingInitial extends TrackingState {}

class TrackingLoading extends TrackingState {}

class TrackingLoaded extends TrackingState {
  final List<Transaction> transactions;
  final List<RecurringRule> recurringRules;
  final List<CategoryRule> categoryRules;

  TrackingLoaded({
    required this.transactions,
    required this.recurringRules,
    required this.categoryRules,
  });

  TrackingLoaded copyWith({
    List<Transaction>? transactions,
    List<RecurringRule>? recurringRules,
    List<CategoryRule>? categoryRules,
  }) {
    return TrackingLoaded(
      transactions: transactions ?? this.transactions,
      recurringRules: recurringRules ?? this.recurringRules,
      categoryRules: categoryRules ?? this.categoryRules,
    );
  }
}

class TrackingError extends TrackingState {
  final String message;
  TrackingError(this.message);
}
