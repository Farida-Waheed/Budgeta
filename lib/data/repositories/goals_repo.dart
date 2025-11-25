import 'package:uuid/uuid.dart';
import '../models/goal.dart';

class GoalsRepository {
  final List<Goal> _goals = [];
  final uuid = const Uuid();

  List<Goal> getAll() => _goals;

  void addGoal({
    required String title,
    required double targetAmount,
  }) {
    _goals.add(
      Goal(
        id: uuid.v4(),
        title: title,
        targetAmount: targetAmount,
        currentAmount: 0,
        createdAt: DateTime.now(),
      ),
    );
  }

  void updateGoal(String id, double addedAmount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final goal = _goals[index];
    _goals[index] = Goal(
      id: goal.id,
      title: goal.title,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount + addedAmount,
      createdAt: goal.createdAt,
      expectedCompletionDate: goal.expectedCompletionDate,
    );
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
  }
}
