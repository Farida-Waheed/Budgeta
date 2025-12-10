// lib/features/dashboard/state/dashboard_state.dart
part of 'dashboard_cubit.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardView view;
  final List<Insight> insights;
  final List<dash_repo.DashboardPreset> presets;
  final List<dash_repo.BudgetIssue> budgetIssues;

  // Extra fields
  final bool isRefreshing;
  final bool isExporting;
  final dash_repo.PeriodComparison? comparison;
  final dash_repo.SpendingReport? lastReport;
  final Map<String, dynamic>? performanceMetrics;

  /// New: export history + trend points
  final List<dash_repo.SpendingReport> exportHistory;
  final List<dash_repo.TimeSeriesPoint> trendPoints;

  DashboardLoaded({
    required this.view,
    required this.insights,
    required this.presets,
    required this.budgetIssues,
    this.isRefreshing = false,
    this.isExporting = false,
    this.comparison,
    this.lastReport,
    this.performanceMetrics,
    this.exportHistory = const [],
    this.trendPoints = const [],
  });

  DashboardLoaded copyWith({
    DashboardView? view,
    List<Insight>? insights,
    List<dash_repo.DashboardPreset>? presets,
    List<dash_repo.BudgetIssue>? budgetIssues,
    bool? isRefreshing,
    bool? isExporting,
    dash_repo.PeriodComparison? comparison,
    dash_repo.SpendingReport? lastReport,
    Map<String, dynamic>? performanceMetrics,
    List<dash_repo.SpendingReport>? exportHistory,
    List<dash_repo.TimeSeriesPoint>? trendPoints,
  }) {
    return DashboardLoaded(
      view: view ?? this.view,
      insights: insights ?? this.insights,
      presets: presets ?? this.presets,
      budgetIssues: budgetIssues ?? this.budgetIssues,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isExporting: isExporting ?? this.isExporting,
      comparison: comparison ?? this.comparison,
      lastReport: lastReport ?? this.lastReport,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      exportHistory: exportHistory ?? this.exportHistory,
      trendPoints: trendPoints ?? this.trendPoints,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
