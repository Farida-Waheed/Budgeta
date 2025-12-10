// lib/features/dashboard/data/dashboard_repository.dart
import '../../../core/models/dashboard_view.dart';
import '../../../core/models/insight.dart';
import '../../../core/models/transaction.dart';

/// Simple time-range + advanced filters for the dashboard.
class DashboardFilter {
  final DateTime from;
  final DateTime to;

  /// Optional advanced filters
  final TransactionType? type; // null = all types
  final String? categoryId; // null/empty = all categories

  const DashboardFilter({
    required this.from,
    required this.to,
    this.type,
    this.categoryId,
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
    final from = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: weekday - 1));
    final to = from.add(const Duration(days: 7));
    return DashboardFilter(from: from, to: to);
  }

  /// All time (from a fixed early date until now)
  factory DashboardFilter.allTime() {
    final from = DateTime(2000, 1, 1); // or any start you like
    final to = DateTime.now();
    return DashboardFilter(from: from, to: to);
  }

  /// Helper to build a new filter with same time range but different advanced filters.
  DashboardFilter withAdvanced({TransactionType? type, String? categoryId}) {
    return DashboardFilter(
      from: from,
      to: to,
      type: type,
      categoryId: categoryId,
    );
  }

  /// Helper to build a new filter with updated time range, keeping advanced filters.
  DashboardFilter withTime({required DateTime from, required DateTime to}) {
    return DashboardFilter(
      from: from,
      to: to,
      type: type,
      categoryId: categoryId,
    );
  }
}

/// Used for "Save Dashboard Preset"
class DashboardPreset {
  final String id;
  final String name;
  final DashboardFilter filter;

  DashboardPreset({required this.id, required this.name, required this.filter});
}

/// Used for "Compare Periods"
class PeriodComparison {
  final DashboardView current;
  final DashboardView previous;

  PeriodComparison({required this.current, required this.previous});
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

/// Simple time-series point for spending trend charts.
class TimeSeriesPoint {
  final DateTime date; // day
  final double value; // total spending that day

  TimeSeriesPoint({required this.date, required this.value});
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

  // UC: View insights (tied to filter)
  Future<List<Insight>> getInsights({
    required String userId,
    required DashboardFilter filter,
  });

  // UC: Drill down to transactions (still by category, but respects advanced filter where relevant)
  Future<List<Transaction>> getTransactionsForCategory({
    required String userId,
    required String categoryId,
    required DashboardFilter filter,
  });

  // UC: Compare periods
  Future<PeriodComparison> compareWithPreviousPeriod({
    required String userId,
    required DashboardFilter currentFilter,
  });

  // UC: Presets
  Future<void> savePreset({
    required String userId,
    required DashboardPreset preset,
  });

  Future<List<DashboardPreset>> getPresets(String userId);

  Future<void> deletePreset({required String userId, required String presetId});

  // UC: Reports / Export
  Future<SpendingReport> generateSpendingReport({
    required String userId,
    required DashboardFilter filter,
    String? title,
  });

  Future<String> exportReportAsPdf(SpendingReport report);
  Future<String> exportReportAsCsv(SpendingReport report);

  /// New: export history per user
  Future<List<SpendingReport>> getExportHistory(String userId);

  // UC: Pipelines / Monitoring
  Future<void> refreshPipelines(String userId);
  Future<Map<String, dynamic>> getPerformanceMetrics();

  // UC: Validate budget logic
  Future<List<BudgetIssue>> validateBudgetLogic({
    required String userId,
    required DashboardFilter filter,
  });

  /// New: Spending trend (time-series) for charts
  Future<List<TimeSeriesPoint>> getSpendingTrend({
    required String userId,
    required DashboardFilter filter,
  });
}
