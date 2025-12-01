// lib/core/models/dashboard_view.dart

class CategorySpending {
  final String categoryId;
  final double amount;

  CategorySpending({
    required this.categoryId,
    required this.amount,
  });
}

class DashboardView {
  final double totalIncome;
  final double totalExpenses;
  final double net;
  final double leftToSpend;
  final List<CategorySpending> topCategories;
  final bool isOnTrackThisPeriod;

  DashboardView({
    required this.totalIncome,
    required this.totalExpenses,
    required this.net,
    required this.leftToSpend,
    required this.topCategories,
    required this.isOnTrackThisPeriod,
  });
}
