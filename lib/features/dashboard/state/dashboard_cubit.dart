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

  DashboardCubit({
    required this.repository,
    required this.userId,
  }) : super(DashboardInitial());

  // -------- View dashboard overview + View insights + Validate budget logic + Presets --------
  Future<void> loadDashboard(dash_repo.DashboardFilter filter) async {
    _lastFilter = filter;
    emit(DashboardLoading());
    try {
      final view = await repository.getDashboardOverview(
        userId: userId,
        filter: filter,
      );
      final insights = await repository.getInsights(
        userId: userId,
        filter: filter,
      );
      final presets = await repository.getPresets(userId);
      final budgetIssues = await repository.validateBudgetLogic(
        userId: userId,
        filter: filter,
      );

      emit(DashboardLoaded(
        view: view,
        insights: insights,
        presets: presets,
        budgetIssues: budgetIssues,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> refresh() async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }
    await loadDashboard(_lastFilter);
  }

  Future<void> changeFilter(dash_repo.DashboardFilter filter) async {
    await loadDashboard(filter);
  }

  Future<void> compareWithPrevious() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    final comparison = await repository.compareWithPreviousPeriod(
      userId: userId,
      currentFilter: _lastFilter,
    );

    emit(currentState.copyWith(comparison: comparison));
  }

  Future<List<Transaction>> drillDownToCategory(String categoryId) {
    return repository.getTransactionsForCategory(
      userId: userId,
      categoryId: categoryId,
      filter: _lastFilter,
    );
  }

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

  Future<void> applyPreset(dash_repo.DashboardPreset preset) async {
    await loadDashboard(preset.filter);
  }

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

    emit(currentState.copyWith(
      isExporting: false,
      lastReport: report,
    ));
  }

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

    emit(currentState.copyWith(
      isRefreshing: false,
      performanceMetrics: metrics,
      view: view,
      insights: insights,
      presets: presets,
      budgetIssues: budgetIssues,
    ));
  }
}
