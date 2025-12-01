// lib/features/dashboard/data/dashboard_repository.dart
import '../../../core/models/dashboard_view.dart';
import '../../../core/models/insight.dart';
import '../../../core/models/transaction.dart';

/// Simple time-range filter for the dashboard.
class DashboardFilter {
  final DateTime from;
  final DateTime to;

  const DashboardFilter({
    required this.from,
    required this.to,
  });

  /// Current month (1st day → first day of next month)
  factory DashboardFilter.currentMonth() {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);
    return DashboardFilter(from: from, to: to);
  }

  /// Last 30 days window.
  factory DashboardFilter.last30Days() {
    final to = DateTime.now();
    final from = to.subtract(const Duration(days: 30));
    return DashboardFilter(from: from, to: to);
  }

  /// This calendar week (Mon–Sun)
  factory DashboardFilter.thisWeek() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Mon, 7 = Sun
    final from = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: weekday - 1));
    final to = from.add(const Duration(days: 7));
    return DashboardFilter(from: from, to: to);
  }
}

/// Used for "Save Dashboard Preset"
class DashboardPreset {
  final String id;
  final String name;
  final DashboardFilter filter;

  DashboardPreset({
    required this.id,
    required this.name,
    required this.filter,
  });
}

/// Used for "Compare Periods"
class PeriodComparison {
  final DashboardView current;
  final DashboardView previous;

  PeriodComparison({
    required this.current,
    required this.previous,
  });
}

/// Used for "Generate Spending Reports" + "Export Report"
class SpendingReport {
  final String id;
  final String title;
  final DashboardFilter filter;
  final DashboardView summary;
  final List<CategorySpending> categories;
  final DateTime generatedAt;

  SpendingReport({
    required this.id,
    required this.title,
    required this.filter,
    required this.summary,
    required this.categories,
    required this.generatedAt,
  });
}

/// Used for "Validate Budget Logic"
class BudgetIssue {
  final String id;
  final String message;
  final String severity; // info / warning / error

  BudgetIssue({
    required this.id,
    required this.message,
    required this.severity,
  });
}

abstract class DashboardRepository {
  // UC: View dashboard overview
  Future<DashboardView> getDashboardOverview({
    required String userId,
    required DashboardFilter filter,
  });

  // UC: View insights (NOW tied to filter)
  Future<List<Insight>> getInsights({
    required String userId,
    required DashboardFilter filter,
  });

  // UC: Drill down to transactions
  Future<List<Transaction>> getTransactionsForCategory({
    required String userId,
    required String categoryId,
    required DashboardFilter filter,
  });

  // ... rest of methods unchanged
  Future<PeriodComparison> compareWithPreviousPeriod({
    required String userId,
    required DashboardFilter currentFilter,
  });

  Future<void> savePreset({
    required String userId,
    required DashboardPreset preset,
  });

  Future<List<DashboardPreset>> getPresets(String userId);
  Future<void> deletePreset({
    required String userId,
    required String presetId,
  });

  Future<SpendingReport> generateSpendingReport({
    required String userId,
    required DashboardFilter filter,
    String? title,
  });

  Future<String> exportReportAsPdf(SpendingReport report);
  Future<String> exportReportAsCsv(SpendingReport report);

  Future<void> refreshPipelines(String userId);
  Future<Map<String, dynamic>> getPerformanceMetrics();

  Future<List<BudgetIssue>> validateBudgetLogic({
    required String userId,
    required DashboardFilter filter,
  });
}