// lib/features/goals/state/goals_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/goal.dart';
import '../data/goals_repository.dart';

part 'goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  final GoalsRepository repository;
  final String userId;

  GoalsCubit({required this.repository, required this.userId})
      : super(GoalsInitial());

  Future<void> loadGoals() async {
    emit(GoalsLoading());
    try {
      final goals = await repository.getGoals(userId);
      emit(GoalsLoaded(goals));
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  Future<void> requestProjection(String goalId) async {
    if (state is! GoalsLoaded) return;
    final current = (state as GoalsLoaded).goals;
    try {
      final proj = await repository.getGoalProjection(goalId);
      final updated = current
          .map((g) => g.id == goalId ? Goal(
            id: g.id,
            userId: g.userId,
            name: g.name,
            targetAmount: g.targetAmount,
            currentAmount: g.currentAmount,
            createdAt: g.createdAt,
            targetDate: g.targetDate,
            projection: proj,
            isPrimary: g.isPrimary,
          ) : g)
          .toList();
      emit(GoalsLoaded(updated));
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }
}
