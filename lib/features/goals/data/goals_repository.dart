// lib/features/goals/data/goals_repository.dart
import '../../../../core/models/goal.dart';

/// -------- Contract / interface ----------
abstract class GoalsRepository {
  // UC: View goals overview
  Future<List<Goal>> getGoals(String userId);

  // UC: Create / edit goal
  Future<Goal> createGoal(Goal goal);
  Future<Goal> updateGoal(Goal goal);

  // UC: Contribute to goal from transaction / manual
  Future<Goal> addContribution({
    required String goalId,
    required double amount,
  });

  // UC: Get AI-driven projection
  Future<GoalProjection> getGoalProjection(String goalId);
}
