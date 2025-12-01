// lib/features/goals/state/goals_state.dart
part of 'goals_cubit.dart';

abstract class GoalsState {}

class GoalsInitial extends GoalsState {}

class GoalsLoading extends GoalsState {}

class GoalsLoaded extends GoalsState {
  final List<Goal> goals;
  GoalsLoaded(this.goals);
}

class GoalsError extends GoalsState {
  final String message;
  GoalsError(this.message);
}
