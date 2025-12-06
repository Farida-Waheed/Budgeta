// lib/features/dashboard/state/dashboard_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/dashboard_view.dart';
import '../../../core/models/insight.dart';
import '../../../core/models/transaction.dart';
import '../data/dashboard_repository.dart' as dash_repo;

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final dash_repo.DashboardRepository repository;
  final String userId;

  dash_repo.DashboardFilter _lastFilter =
      dash_repo.DashboardFilter.currentMonth();
  dash_repo.DashboardFilter get currentFilter => _lastFilter;

  DashboardCubit({
    required this.repository,
    required this.userId,
  }) : super(DashboardInitial());

  /// Main loader: overview + insights + presets + budget issues
  Future<void> loadDashboard([dash_repo.DashboardFilter? filter]) async {
    final effectiveFilter = filter ?? _lastFilter;
    _lastFilter = effectiveFilter;

    emit(DashboardLoading());
    try {
      final view = await repository.getDashboardOverview(
        userId: userId,
        filter: effectiveFilter,
      );
      final insights = await repository.getInsights(
        userId: userId,
        filter: effectiveFilter,
      );
      final presets = await repository.getPresets(userId);
      final budgetIssues = await repository.validateBudgetLogic(
        userId: userId,
        filter: effectiveFilter,
      );

      emit(
        DashboardLoaded(
          view: view,
          insights: insights,
          presets: presets,
          budgetIssues: budgetIssues,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  /// Refresh using the last filter
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }
    await loadDashboard(_lastFilter);
  }

  /// Change filter (week, month, etc.)
  Future<void> changeFilter(dash_repo.DashboardFilter filter) async {
    await loadDashboard(filter);
  }

  /// Compare current period with previous period
  Future<void> compareWithPrevious() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    final comparison = await repository.compareWithPreviousPeriod(
      userId: userId,
      currentFilter: _lastFilter,
    );

    emit(currentState.copyWith(comparison: comparison));
  }

  /// Drill down to transactions of a single category
  Future<List<Transaction>> drillDownToCategory(String categoryId) {
    return repository.getTransactionsForCategory(
      userId: userId,
      categoryId: categoryId,
      filter: _lastFilter,
    );
  }

  /// Save current filter as a preset
  Future<void> savePreset(String name) async {
    final preset = dash_repo.DashboardPreset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      filter: _lastFilter,
    );
    await repository.savePreset(userId: userId, preset: preset);

    final currentState = state;
    if (currentState is DashboardLoaded) {
      final presets = await repository.getPresets(userId);
      emit(currentState.copyWith(presets: presets));
    }
  }

  /// Apply an existing preset
  Future<void> applyPreset(dash_repo.DashboardPreset preset) async {
    await loadDashboard(preset.filter);
  }

  /// Generate and export report (PDF or CSV)
  Future<void> generateAndExport({required bool asPdf}) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    emit(currentState.copyWith(isExporting: true));

    final report = await repository.generateSpendingReport(
      userId: userId,
      filter: _lastFilter,
    );

    if (asPdf) {
      await repository.exportReportAsPdf(report);
    } else {
      await repository.exportReportAsCsv(report);
    }

    emit(
      currentState.copyWith(
        isExporting: false,
        lastReport: report,
      ),
    );
  }

  /// Refresh pipelines + re-calc view + insights
  Future<void> refreshPipelines() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    emit(currentState.copyWith(isRefreshing: true));

    await repository.refreshPipelines(userId);

    final metrics = await repository.getPerformanceMetrics();
    final view = await repository.getDashboardOverview(
      userId: userId,
      filter: _lastFilter,
    );
    final insights = await repository.getInsights(
      userId: userId,
      filter: _lastFilter,
    );
    final presets = await repository.getPresets(userId);
    final budgetIssues = await repository.validateBudgetLogic(
      userId: userId,
      filter: _lastFilter,
    );

    emit(
      currentState.copyWith(
        isRefreshing: false,
        performanceMetrics: metrics,
        view: view,
        insights: insights,
        presets: presets,
        budgetIssues: budgetIssues,
      ),
    );
  }
}
