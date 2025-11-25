import 'package:flutter/material.dart';
import '../../data/repositories/goals_repo.dart';
import '../../data/models/goal.dart';

class GoalController extends ChangeNotifier {
  final GoalsRepository repo;

  GoalController(this.repo);

  List<Goal> get goals => repo.getAll();

  void addGoal(String title, double targetAmount) {
    repo.addGoal(
      title: title,
      targetAmount: targetAmount,
    );
    notifyListeners();
  }

  void updateGoal(String id, double amount) {
    repo.updateGoal(id, amount);
    notifyListeners();
  }

  void deleteGoal(String id) {
    repo.deleteGoal(id);
    notifyListeners();
  }
}
