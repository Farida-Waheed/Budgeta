// lib/features/tracking/state/tracking_state.dart
part of 'tracking_cubit.dart';

abstract class TrackingState {}

class TrackingInitial extends TrackingState {}

class TrackingLoading extends TrackingState {}

class TrackingLoaded extends TrackingState {
  final List<Transaction> transactions;
  final List<RecurringRule> recurringRules;

  TrackingLoaded({
    required this.transactions,
    required this.recurringRules,
  });
}

class TrackingError extends TrackingState {
  final String message;
  TrackingError(this.message);
}
