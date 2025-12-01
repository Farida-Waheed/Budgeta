// lib/features/dashboard/state/dashboard_state.dart
part of 'dashboard_cubit.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardView view;
  final List<Insight> insights;

  // New fields for the extra use cases
  final List<dash_repo.DashboardPreset> presets;
  final dash_repo.PeriodComparison? comparison;
  final List<dash_repo.BudgetIssue> budgetIssues;
  final dash_repo.SpendingReport? lastReport;
  final Map<String, dynamic>? performanceMetrics;
  final bool isExporting;
  final bool isRefreshing;

  DashboardLoaded({
    required this.view,
    required this.insights,
    this.presets = const [],
    this.comparison,
    this.budgetIssues = const [],
    this.lastReport,
    this.performanceMetrics,
    this.isExporting = false,
    this.isRefreshing = false,
  });

  DashboardLoaded copyWith({
    DashboardView? view,
    List<Insight>? insights,
    List<dash_repo.DashboardPreset>? presets,
    dash_repo.PeriodComparison? comparison,
    List<dash_repo.BudgetIssue>? budgetIssues,
    dash_repo.SpendingReport? lastReport,
    Map<String, dynamic>? performanceMetrics,
    bool? isExporting,
    bool? isRefreshing,
  }) {
    return DashboardLoaded(
      view: view ?? this.view,
      insights: insights ?? this.insights,
      presets: presets ?? this.presets,
      comparison: comparison ?? this.comparison,
      budgetIssues: budgetIssues ?? this.budgetIssues,
      lastReport: lastReport ?? this.lastReport,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      isExporting: isExporting ?? this.isExporting,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
