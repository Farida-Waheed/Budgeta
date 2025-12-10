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

  /// UC: Get AI projection for a specific goal
  Future<void> requestProjection(String goalId) async {
    if (state is! GoalsLoaded) return;
    final current = (state as GoalsLoaded).goals;
    try {
      final proj = await repository.getGoalProjection(goalId);
      final updated = current
          .map(
            (g) => g.id == goalId
                ? Goal(
                    id: g.id,
                    userId: g.userId,
                    name: g.name,
                    targetAmount: g.targetAmount,
                    currentAmount: g.currentAmount,
                    createdAt: g.createdAt,
                    targetDate: g.targetDate,
                    projection: proj,
                    isPrimary: g.isPrimary,
                  )
                : g,
          )
          .toList();
      emit(GoalsLoaded(updated));
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }

  /// UC: Create a new goal (from the bottom sheet)
  Future<void> createGoal({
    required String name,
    required double target,
    required double current,
    DateTime? deadline,
  }) async {
    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: name,
      targetAmount: target,
      currentAmount: current,
      createdAt: DateTime.now(),
      targetDate: deadline,
      isPrimary: false,
    );

    try {
      final saved = await repository.createGoal(newGoal);

      if (state is GoalsLoaded) {
        final list = (state as GoalsLoaded).goals;
        emit(GoalsLoaded([saved, ...list]));
      } else {
        await loadGoals();
      }
    } catch (e) {
      emit(GoalsError(e.toString()));
    }
  }
}
