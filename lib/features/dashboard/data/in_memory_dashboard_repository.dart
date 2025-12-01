// lib/features/dashboard/data/in_memory_dashboard_repository.dart
import 'dart:math';

import '../../../core/models/dashboard_view.dart';
import '../../../core/models/insight.dart';
import '../../../core/models/transaction.dart';
import '../../tracking/data/tracking_repository.dart';

import 'dashboard_repository.dart';

class InMemoryDashboardRepository implements DashboardRepository {
  final TrackingRepository trackingRepository;
  final _rng = Random();

  final Map<String, List<DashboardPreset>> _presetsByUser = {};

  InMemoryDashboardRepository({required this.trackingRepository});

  // -------- DASHBOARD OVERVIEW --------
  @override
  Future<DashboardView> getDashboardOverview({
    required String userId,
    required DashboardFilter filter,
  }) async {
    final txs = await trackingRepository.getTransactions(
      userId: userId,
      from: filter.from,
      to: filter.to,
    );

    double income = 0;
    double expenses = 0;
    final byCategory = <String, double>{};

    for (final t in txs) {
      if (t.type == TransactionType.income) {
        // ✅ Income affects income/net only, NOT spending per category
        income += t.amount;
      } else {
        // Expense
        expenses += t.amount;
        // ✅ Only count EXPENSES in category spending
        byCategory[t.categoryId] =
            (byCategory[t.categoryId] ?? 0) + t.amount;
      }
    }

    final net = income - expenses;
    final leftToSpend = net > 0 ? net : 0.0;

    final topCategories = byCategory.entries
        .map(
          (e) => CategorySpending(
            categoryId: e.key,
            amount: e.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // ✅ Only mark as "overspending" when there is actual data
    final hasData = income > 0 || expenses > 0;

    final isOnTrack = !hasData
        ? true // no data yet → don't scare the user
        : (income == 0)
            ? false // expenses but no income → overspending
            : (expenses / income) < 0.8;

    return DashboardView(
      totalIncome: income,
      totalExpenses: expenses,
      net: net,
      leftToSpend: leftToSpend,
      topCategories: topCategories,
      isOnTrackThisPeriod: isOnTrack,
    );
  }

  // ---------- SMART INSIGHTS ----------
  @override
  Future<List<Insight>> getInsights({
    required String userId,
    required DashboardFilter filter,
  }) async {
    final now = DateTime.now();

    // Current period view
    final current = await getDashboardOverview(
      userId: userId,
      filter: filter,
    );

    // Previous period view (same length window)
    final diff = filter.to.difference(filter.from);
    final prevTo = filter.from;
    final prevFrom = prevTo.subtract(diff);
    final previous = await getDashboardOverview(
      userId: userId,
      filter: DashboardFilter(from: prevFrom, to: prevTo),
    );

    final insights = <Insight>[];

    // 1) Overspending trend
    if (previous.totalExpenses > 0 &&
        current.totalExpenses > previous.totalExpenses) {
      insights.add(
        Insight(
          id: 'trend-expenses-up',
          userId: userId,
          type: InsightType.trend,
          title: 'You spent more this period',
          description:
              'Your total spending increased compared to the previous period.',
          createdAt: now,
        ),
      );
    }

    // 2) Dominant category (only expenses, because topCategories is expenses-only now)
    if (current.topCategories.isNotEmpty && current.totalExpenses > 0) {
      final top = current.topCategories.first;
      final percent = top.amount / current.totalExpenses;
      if (percent >= 0.3) {
        insights.add(
          Insight(
            id: 'top-category',
            userId: userId,
            type: InsightType.trend,
            title: 'Most of your spending is in ${top.categoryId}',
            description:
                'Around ${(percent * 100).toStringAsFixed(0)}% of your expenses this period are in ${top.categoryId}.',
            createdAt: now,
          ),
        );
      }
    }

    // 3) Savings tip if user has positive net
    if (current.net > 0) {
      insights.add(
        Insight(
          id: 'net-positive',
          userId: userId,
          type: InsightType.tip,
          title: 'You can save part of your surplus',
          description:
              'You have a positive net this period. Consider moving a portion into savings to protect it.',
          createdAt: now,
        ),
      );
    }

    // 4) Basic motivational tip if nothing else was added
    if (insights.isEmpty) {
      insights.add(
        Insight(
          id: 'keep-going',
          userId: userId,
          type: InsightType.tip,
          title: 'Keep logging your money moves',
          description:
              'The more consistently you track, the better Budgeta can coach you.',
          createdAt: now,
        ),
      );
    }

    return insights;
  }

  // -------- Drill Down to Transactions --------
  @override
  Future<List<Transaction>> getTransactionsForCategory({
    required String userId,
    required String categoryId,
    required DashboardFilter filter,
  }) async {
    final txs = await trackingRepository.getTransactions(
      userId: userId,
      from: filter.from,
      to: filter.to,
    );
    return txs.where((t) => t.categoryId == categoryId).toList();
  }

  // -------- Compare Periods --------
  @override
  Future<PeriodComparison> compareWithPreviousPeriod({
    required String userId,
    required DashboardFilter currentFilter,
  }) async {
    final current = await getDashboardOverview(
      userId: userId,
      filter: currentFilter,
    );

    final diff = currentFilter.to.difference(currentFilter.from);
    final previousTo = currentFilter.from;
    final previousFrom = previousTo.subtract(diff);

    final previous = await getDashboardOverview(
      userId: userId,
      filter: DashboardFilter(from: previousFrom, to: previousTo),
    );

    return PeriodComparison(current: current, previous: previous);
  }

  // -------- Presets --------
  @override
  Future<void> savePreset({
    required String userId,
    required DashboardPreset preset,
  }) async {
    final list = _presetsByUser.putIfAbsent(userId, () => []);
    list.removeWhere((p) => p.id == preset.id);
    list.add(preset);
  }

  @override
  Future<List<DashboardPreset>> getPresets(String userId) async {
    return List.unmodifiable(_presetsByUser[userId] ?? []);
  }

  @override
  Future<void> deletePreset({
    required String userId,
    required String presetId,
  }) async {
    final list = _presetsByUser[userId];
    list?.removeWhere((p) => p.id == presetId);
  }

  // -------- Reports + Export --------
  @override
  Future<SpendingReport> generateSpendingReport({
    required String userId,
    required DashboardFilter filter,
    String? title,
  }) async {
    final summary = await getDashboardOverview(
      userId: userId,
      filter: filter,
    );
    final report = SpendingReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'Spending report',
      filter: filter,
      summary: summary,
      categories: summary.topCategories,
      generatedAt: DateTime.now(),
    );
    return report;
  }

  @override
  Future<String> exportReportAsPdf(SpendingReport report) async {
    // In a real app this would create a PDF and return a file path.
    await Future.delayed(const Duration(milliseconds: 400));
    return '/fake/path/report_${report.id}.pdf';
  }

  @override
  Future<String> exportReportAsCsv(SpendingReport report) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return '/fake/path/report_${report.id}.csv';
  }

  // -------- Pipelines + Monitoring --------
  @override
  Future<void> refreshPipelines(String userId) async {
    // Here you would typically sync remote data, recalc aggregates, etc.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    // Fake monitoring values
    return {
      'lastRefreshMs': 250 + _rng.nextInt(200),
      'lastReportMs': 500 + _rng.nextInt(300),
    };
  }

  // -------- Validate Budget Logic --------
  @override
  Future<List<BudgetIssue>> validateBudgetLogic({
    required String userId,
    required DashboardFilter filter,
  }) async {
    final view = await getDashboardOverview(userId: userId, filter: filter);
    final issues = <BudgetIssue>[];

    // Do not show alerts if there is literally no data
    final hasData = view.totalIncome > 0 || view.totalExpenses > 0;
    if (!hasData) {
      return issues;
    }

    if (view.totalIncome == 0) {
      // Expenses but no income → overspending/unstable situation
      if (view.totalExpenses > 0) {
        issues.add(
          BudgetIssue(
            id: 'b0',
            message:
                'You have expenses but no recorded income for this period.',
            severity: 'warning',
          ),
        );
      }
    } else {
      final ratio = view.totalExpenses / view.totalIncome;
      if (ratio > 0.8) {
        issues.add(
          BudgetIssue(
            id: 'b1',
            message:
                'Your expenses are more than 80% of your income this period.',
            severity: 'warning',
          ),
        );
      }
    }

    if (view.leftToSpend <= 0 && view.totalIncome > 0) {
      issues.add(
        BudgetIssue(
          id: 'b2',
          message: 'You have no money left to spend this period.',
          severity: 'error',
        ),
      );
    }

    return issues;
  }
}
