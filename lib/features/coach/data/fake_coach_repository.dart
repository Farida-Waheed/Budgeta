// lib/features/goals/data/fake_goals_repository.dart
import 'dart:async';

import '../../../core/models/goal.dart';
import 'goals_repository.dart';

class FakeGoalsRepository implements GoalsRepository {
  final List<Goal> _store = [];

  FakeGoalsRepository() {
    final now = DateTime.now();
    _store.addAll([
      Goal(
        id: 'g1',
        userId: 'demo-user',
        name: 'Dream Vacation',
        targetAmount: 5000,
        currentAmount: 1250,
        createdAt: now.subtract(const Duration(days: 30)),
        targetDate: DateTime(now.year + 1, 6, 1),
        isPrimary: true,
      ),
      Goal(
        id: 'g2',
        userId: 'demo-user',
        name: 'Emergency Fund',
        targetAmount: 10000,
        currentAmount: 3200,
        createdAt: now.subtract(const Duration(days: 60)),
        targetDate: DateTime(now.year + 1, 12, 3),
      ),
    ]);
  }

  Future<T> _delay<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return value;
  }

  @override
  Future<List<Goal>> getGoals(String userId) {
    final list = _store.where((g) => g.userId == userId).toList();
    // primary goal first
    list.sort((a, b) {
      if (a.isPrimary == b.isPrimary) {
        return a.createdAt.compareTo(b.createdAt);
      }
      return a.isPrimary ? -1 : 1;
    });
    return _delay(list);
  }

  @override
  Future<Goal> createGoal(Goal goal) {
    _store.add(goal);
    return _delay(goal);
  }

  @override
  Future<Goal> updateGoal(Goal goal) {
    final index = _store.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _store[index] = goal;
    }
    return _delay(goal);
  }

  @override
  Future<Goal> addContribution({
    required String goalId,
    required double amount,
  }) async {
    final index = _store.indexWhere((g) => g.id == goalId);
    if (index == -1) {
      throw Exception('Goal not found');
    }
    final g = _store[index];
    final updated = Goal(
      id: g.id,
      userId: g.userId,
      name: g.name,
      targetAmount: g.targetAmount,
      currentAmount: g.currentAmount + amount,
      createdAt: g.createdAt,
      targetDate: g.targetDate,
      projection: g.projection,
      isPrimary: g.isPrimary,
    );
    _store[index] = updated;
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

    // super simple “AI”: suggest finishing in 6 months
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
