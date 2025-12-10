// lib/features/goals/data/in_memory_goals_repository.dart
import '../../../core/models/goal.dart';
import 'goals_repository.dart';

/// -------- In-memory implementation ----------
/// Only stores whatever the user creates in this session.
/// No static goals are pre-loaded.
class InMemoryGoalsRepository implements GoalsRepository {
  final List<Goal> _store = [];

  Future<T> _delay<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return value;
  }

  @override
  Future<List<Goal>> getGoals(String userId) async {
    final list = _store.where((g) => g.userId == userId).toList();

    // Primary first, then by creation date
    list.sort((a, b) {
      if (a.isPrimary == b.isPrimary) {
        return a.createdAt.compareTo(b.createdAt);
      }
      return a.isPrimary ? -1 : 1;
    });

    return _delay(list);
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    _store.add(goal);
    return _delay(goal);
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final idx = _store.indexWhere((g) => g.id == goal.id);
    if (idx != -1) {
      _store[idx] = goal;
    }
    return _delay(goal);
  }

  @override
  Future<Goal> addContribution({
    required String goalId,
    required double amount,
  }) async {
    final idx = _store.indexWhere((g) => g.id == goalId);
    if (idx == -1) {
      throw Exception('Goal not found');
    }

    final g = _store[idx];
    final updated = g.copyWith(currentAmount: g.currentAmount + amount);

    _store[idx] = updated;
    return _delay(updated);
  }

  @override
  Future<GoalProjection> getGoalProjection(String goalId) async {
    final goal = _store.firstWhere((g) => g.id == goalId);

    final remaining = goal.targetAmount - goal.currentAmount;
    if (remaining <= 0) {
      return _delay(
        GoalProjection(
          estimatedCompletionDate: DateTime.now(),
          suggestedMonthlySaving: 0,
        ),
      );
    }

    // Simple “AI”: finish in ~6 months
    const months = 6;
    final suggested = remaining / months;
    final completion = DateTime.now().add(const Duration(days: 30 * months));

    return _delay(
      GoalProjection(
        estimatedCompletionDate: completion,
        suggestedMonthlySaving: suggested,
      ),
    );
  }
}
