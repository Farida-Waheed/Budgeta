import 'package:flutter/material.dart';
import '../../data/repositories/dashboard_repo.dart';

class DashboardController extends ChangeNotifier {
  final DashboardRepository repo;

  DashboardController(this.repo);

  double get monthlyExpense => repo.getMonthlyExpense();
  double get monthlyIncome => repo.getMonthlyIncome();
  Map<String, double> get categoryBreakdown => repo.getCategoryBreakdown();

  void refresh() {
    notifyListeners();
  }
}
