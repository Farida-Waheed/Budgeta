import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../app/router.dart';
import '../../../../shared/bottom_nav.dart';

// 👇 ADD THIS (adjust path if your profile screen is elsewhere)
import '../../../../features/profile/presentation/screens/profile_screen.dart';

// State
import '../../state/dashboard_cubit.dart';
import '../../../../features/tracking/state/tracking_cubit.dart';

// Models
import '../../../../core/models/transaction.dart';
import '../../../../core/models/dashboard_view.dart';
import '../../../../core/models/insight.dart';
import '../../data/dashboard_repository.dart' as dash_repo;

// ⬇️ NEW: to use the sheet-style Add Transaction UI
import '../../../../features/tracking/presentation/screens/add_transaction_screen.dart';

// Local widgets
import '../widgets/time_filter_bar.dart';
import '../widgets/insights_section.dart';
import '../widgets/budget_health_section.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 0),

      // ➕ Gradient FAB to add transaction
      floatingActionButton: const _AddTransactionFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is! DashboardLoaded) {
              return const SizedBox.shrink();
            }

            final view = state.view;
            final cubit = context.read<DashboardCubit>();

            // Recent activity from TrackingCubit
            final trackingState = context.watch<TrackingCubit>().state;
            List<Transaction> recent = [];
            if (trackingState is TrackingLoaded) {
              recent = List<Transaction>.from(
                trackingState.transactions,
              ).take(5).toList();
            }

            // Header is fixed, content scrolls under it
            return Column(
              children: [
                _DashboardHeader(view: view),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => cubit.refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const SizedBox(height: 12),

                        // ---------------------------
                        //  TIME FILTER + ACTIONS ROW
                        // ---------------------------
                        TimeFilterBar(
                          onFilterChanged: (dash_repo.DashboardFilter f) {
                            cubit.changeTimeRange(f);
                          },
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => cubit.compareWithPrevious(),
                              icon: const Icon(
                                Icons.compare_arrows_rounded,
                                size: 18,
                              ),
                              label: const Text('Compare with previous'),
                            ),
                            const Spacer(),
                            _ExportButtons(isExporting: state.isExporting),
                          ],
                        ),

                        if (state.lastReport != null ||
                            state.performanceMetrics != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                              bottom: 4.0,
                            ),
                            child: _MetricsHint(state: state),
                          ),

                        const SizedBox(height: 8),

                        // ---------------------------
                        //  ADVANCED FILTERS (type + category)
                        // ---------------------------
                        _AdvancedFiltersRow(
                          filter: cubit.currentFilter,
                          availableCategories: view.topCategories,
                          onTypeChanged: (TransactionType? type) {
                            final current = cubit.currentFilter;
                            cubit.changeAdvancedFilters(
                              typeFilter: type,
                              categoryId: current.categoryId,
                            );
                          },
                          onCategoryChanged: (String? categoryId) {
                            final current = cubit.currentFilter;
                            cubit.changeAdvancedFilters(
                              typeFilter: current.type,
                              categoryId: categoryId,
                            );
                          },
                          onClearFilters: () {
                            cubit.changeAdvancedFilters(
                              typeFilter: null,
                              categoryId: null,
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // ---------------------------
                        //  MAIN CONTENT
                        // ---------------------------
                        _QuickStatsRow(view: view),
                        const SizedBox(height: 16),

                        // Comparison banner (if user tapped "Compare with previous")
                        if (state.comparison != null) ...[
                          _ComparisonBanner(comparison: state.comparison!),
                          const SizedBox(height: 16),
                        ],

                        // Smart Insights
                        InsightsSection(insights: state.insights),
                        const SizedBox(height: 20),

                        // Spending trend (time series)
                        _TrendSection(points: state.trendPoints),
                        const SizedBox(height: 20),

                        // Top spending with drill-down
                        _TopSpendingSection(
                          view: view,
                          onCategoryTap:
                              (String categoryId, String displayName) async {
                                final txs = await cubit.drillDownToCategory(
                                  categoryId,
                                );
                                // ignore: use_build_context_synchronously
                                _showCategoryTransactionsSheet(
                                  context: context,
                                  title: displayName,
                                  transactions: txs,
                                );
                              },
                        ),
                        const SizedBox(height: 20),

                        // Budget health (validate budget logic)
                        BudgetHealthSection(issues: state.budgetIssues),
                        const SizedBox(height: 20),

                        // Presets row
                        _PresetsSection(
                          presets: state.presets,
                          onSavePreset: () async {
                            final name = await _askPresetNameDialog(context);
                            if (name == null || name.trim().isEmpty) return;
                            await cubit.savePreset(name.trim());
                          },
                          onApplyPreset:
                              (dash_repo.DashboardPreset preset) async {
                                await cubit.applyPreset(preset);
                              },
                        ),
                        const SizedBox(height: 20),

                        // Export history (reports)
                        _ExportHistorySection(history: state.exportHistory),
                        const SizedBox(height: 20),

                        // Recent activity
                        _RecentActivitySection(transactions: recent),
                        const SizedBox(height: 24),

                        // Pipelines refresh (advanced)
                        Center(
                          child: TextButton.icon(
                            onPressed: () => cubit.refreshPipelines(),
                            icon: state.isRefreshing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.sync_rounded, size: 18),
                            label: Text(
                              state.isRefreshing
                                  ? 'Refreshing data…'
                                  : 'Refresh data pipelines',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// FAB with gradient + icon (for Add Transaction)
class _AddTransactionFab extends StatelessWidget {
  const _AddTransactionFab();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showAddTransactionBottomSheet(
          context,
          preselectedType: TransactionType.expense,
        );
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [BudgetaColors.primary, BudgetaColors.deep],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

/// ==========================================================
/// HEADER (gradient + total balance card)
/// ==========================================================
class _DashboardHeader extends StatelessWidget {
  final DashboardView view;

  const _DashboardHeader({required this.view});

  @override
  Widget build(BuildContext context) {
    final double income = view.totalIncome;
    final double expenses = view.totalExpenses;
    final double net = view.net;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [BudgetaColors.primary, BudgetaColors.deep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting + circular sparkle button
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Beautiful! ✨',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ready to sparkle today?',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Main balance card – styled like challenge dialog
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: BudgetaColors.accentLight.withValues(alpha: 0.9),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    color: BudgetaColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${net.toStringAsFixed(2)} EGP',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: BudgetaColors.deep,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 16,
                          color: Color.fromRGBO(67, 160, 71, 1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${income.toStringAsFixed(2)} EGP',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_down_rounded,
                          size: 16,
                          color: BudgetaColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${expenses.toStringAsFixed(2)} EGP',
                          style: const TextStyle(
                            fontSize: 12,
                            color: BudgetaColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔻 everything below this is unchanged from your version

/// ==========================================================
/// ADVANCED FILTERS (type + category)
/// ==========================================================
class _AdvancedFiltersRow extends StatelessWidget {
  final dash_repo.DashboardFilter filter;
  final List<CategorySpending> availableCategories;
  final void Function(TransactionType?) onTypeChanged;
  final void Function(String?) onCategoryChanged;
  final VoidCallback onClearFilters;

  const _AdvancedFiltersRow({
    required this.filter,
    required this.availableCategories,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onClearFilters,
  });

  String _prettyCategory(String id) {
    if (id.isEmpty) return 'Other';
    switch (id) {
      case 'food':
        return 'Groceries';
      case 'coffee':
        return 'Coffee';
      case 'rent':
        return 'Rent';
      case 'transport':
        return 'Transport';
      case 'subscription':
        return 'Subscriptions';
      case 'salary':
        return 'Salary';
      default:
        return id[0].toUpperCase() + id.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = filter.type;
    final selectedCategoryId = filter.categoryId;
    final hasFilters = selectedType != null || selectedCategoryId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced filters',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: selectedType == null,
                onSelected: (_) => onTypeChanged(null),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Expenses'),
                selected: selectedType == TransactionType.expense,
                onSelected: (_) => onTypeChanged(TransactionType.expense),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Income'),
                selected: selectedType == TransactionType.income,
                onSelected: (_) => onTypeChanged(TransactionType.income),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () async {
                  if (availableCategories.isEmpty) {
                    onCategoryChanged(null);
                    return;
                  }

                  final uniqueIds = {
                    for (final c in availableCategories) c.categoryId,
                  }.toList();

                  final chosen = await showModalBottomSheet<String?>(
                    context: context,
                    builder: (ctx) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ListTile(
                              title: Text(
                                'Filter by category',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: BudgetaColors.deep,
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              title: const Text('All categories'),
                              onTap: () => Navigator.of(ctx).pop(null),
                            ),
                            for (final id in uniqueIds)
                              ListTile(
                                title: Text(_prettyCategory(id)),
                                onTap: () => Navigator.of(ctx).pop(id),
                              ),
                          ],
                        ),
                      );
                    },
                  );

                  onCategoryChanged(chosen);
                },
                style: TextButton.styleFrom(
                  foregroundColor: BudgetaColors.primary,
                  textStyle: const TextStyle(fontSize: 12.5),
                ),
                icon: const Icon(Icons.filter_list_rounded, size: 16),
                label: Text(
                  selectedCategoryId == null
                      ? 'Category: All'
                      : 'Category: ${_prettyCategory(selectedCategoryId)}',
                ),
              ),
              if (hasFilters)
                IconButton(
                  tooltip: 'Clear advanced filters',
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_rounded, size: 18),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ==========================================================
/// QUICK STATS
/// ==========================================================
class _QuickStatsRow extends StatelessWidget {
  final DashboardView view;

  const _QuickStatsRow({required this.view});

  @override
  Widget build(BuildContext context) {
    final totalThisPeriod = view.totalExpenses;
    final distinctCategories = view.topCategories.length;
    final leftToSpend = view.leftToSpend;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats 💖',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickStatCard(
                icon: Icons.currency_pound,
                title: 'E£${totalThisPeriod.toStringAsFixed(2)}',
                subtitle: 'Total spending',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickStatCard(
                icon: Icons.savings_rounded,
                title: '$distinctCategories',
                subtitle: 'Categories',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickStatCard(
                icon: Icons.account_balance_wallet_rounded,
                title: 'E£${leftToSpend.toStringAsFixed(2)}',
                subtitle: 'Left to spend',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickStatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: BudgetaColors.accentLight.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  BudgetaColors.accentLight.withValues(alpha: 0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Icon(icon, size: 24, color: BudgetaColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: BudgetaColors.deep,
              fontWeight: FontWeight.w700,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: BudgetaColors.textMuted,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// ==========================================================
/// COMPARISON BANNER (current vs previous period)
/// ==========================================================
class _ComparisonBanner extends StatelessWidget {
  final dash_repo.PeriodComparison comparison;

  const _ComparisonBanner({required this.comparison});

  double _percentChange(double oldVal, double newVal) {
    if (oldVal == 0) return 0;
    return ((newVal - oldVal) / oldVal) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final current = comparison.current;
    final previous = comparison.previous;

    final incomeChange = _percentChange(
      previous.totalIncome,
      current.totalIncome,
    );
    final expenseChange = _percentChange(
      previous.totalExpenses,
      current.totalExpenses,
    );

    String formatChange(double v) {
      if (v == 0) return 'no change';
      final abs = v.abs().toStringAsFixed(1);
      return v > 0 ? '+$abs%' : '-$abs%';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: BudgetaColors.accentLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: BudgetaColors.accentLight.withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compared to previous period',
            style: TextStyle(
              color: BudgetaColors.deep,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Income: ${formatChange(incomeChange)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: BudgetaColors.deep,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_down_rounded,
                      size: 16,
                      color: BudgetaColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Expenses: ${formatChange(expenseChange)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: BudgetaColors.deep,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ==========================================================
/// SPENDING TREND (simple bar chart)
/// ==========================================================
class _TrendSection extends StatelessWidget {
  final List<dash_repo.TimeSeriesPoint> points;

  const _TrendSection({required this.points});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending trend 📈',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        if (points.isEmpty)
          const Text(
            'No spending trend yet. Track more expenses to see your pattern.',
            style: TextStyle(fontSize: 12, color: BudgetaColors.textMuted),
          )
        else
          SizedBox(height: 120, child: _TrendBars(points: points)),
      ],
    );
  }
}

class _TrendBars extends StatelessWidget {
  final List<dash_repo.TimeSeriesPoint> points;

  const _TrendBars({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxValue = points
        .map((e) => e.value)
        .fold<double>(0, (a, b) => b > a ? b : a);
    const maxBarHeight = 80.0;

    String shortDate(DateTime d) {
      return '${d.month}/${d.day}';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final p in points)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 12,
                      height: maxValue == 0
                          ? 0
                          : (p.value / maxValue) * maxBarHeight,
                      decoration: BoxDecoration(
                        color: BudgetaColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shortDate(p.date),
                  style: const TextStyle(
                    fontSize: 10,
                    color: BudgetaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// ==========================================================
/// TOP SPENDING (with drill-down)
/// ==========================================================
typedef CategoryTapCallback =
    void Function(String categoryId, String displayName);

class _TopSpendingSection extends StatelessWidget {
  final DashboardView view;
  final CategoryTapCallback? onCategoryTap;

  const _TopSpendingSection({required this.view, this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final totalExpenses = view.totalExpenses;
    final categories = view.topCategories.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Top Spending ✨',
              style: TextStyle(
                color: BudgetaColors.deep,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Spacer(),
            Icon(Icons.favorite_border, size: 18, color: BudgetaColors.primary),
          ],
        ),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          const Text(
            'No spending data yet. Start logging your expenses!',
            style: TextStyle(fontSize: 12, color: BudgetaColors.textMuted),
          )
        else
          Column(
            children: [
              for (final c in categories)
                _TopSpendingRow(
                  categoryId: c.categoryId,
                  label: _prettyCategory(c.categoryId),
                  amount: c.amount,
                  percent: totalExpenses == 0
                      ? 0
                      : (c.amount / totalExpenses).clamp(0, 1),
                  onTap: onCategoryTap,
                ),
            ],
          ),
      ],
    );
  }

  String _prettyCategory(String id) {
    switch (id) {
      case 'food':
        return 'Groceries';
      case 'coffee':
        return 'Coffee';
      case 'rent':
        return 'Rent';
      case 'transport':
        return 'Transport';
      case 'subscription':
        return 'Subscriptions';
      case 'salary':
        return 'Salary';
      default:
        if (id.isEmpty) return 'Other';
        return id[0].toUpperCase() + id.substring(1);
    }
  }
}

class _TopSpendingRow extends StatelessWidget {
  final String categoryId;
  final String label;
  final double amount;
  final double percent;
  final CategoryTapCallback? onTap;

  const _TopSpendingRow({
    required this.categoryId,
    required this.label,
    required this.amount,
    required this.percent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pctLabel = '${(percent * 100).toStringAsFixed(0)}%';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap == null ? null : () => onTap!(categoryId, label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BudgetaColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${amount.toStringAsFixed(2)} EGP',
                  style: const TextStyle(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: BudgetaColors.accentLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                    color: BudgetaColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pctLabel,
              style: const TextStyle(
                color: BudgetaColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================================================
/// RECENT ACTIVITY
/// ==========================================================
class _RecentActivitySection extends StatelessWidget {
  final List<Transaction> transactions;

  const _RecentActivitySection({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity 💫',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const Text(
            'No recent transactions yet. Add your first expense or income!',
            style: TextStyle(fontSize: 12, color: BudgetaColors.textMuted),
          )
        else
          Column(
            children: [
              for (final t in transactions) _RecentTile(transaction: t),
            ],
          ),
      ],
    );
  }
}

class _RecentTile extends StatelessWidget {
  final Transaction transaction;

  const _RecentTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final sign = isExpense ? '-' : '+';
    final color = isExpense ? BudgetaColors.primary : BudgetaColors.success;
    final dateStr = transaction.date.toLocal().toString().split(' ').first;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BudgetaColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isExpense
                  ? BudgetaColors.accentLight.withValues(alpha: 0.5)
                  : BudgetaColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpense
                  ? Icons.trending_down_rounded
                  : Icons.trending_up_rounded,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note ?? 'No note',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: BudgetaColors.deep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: BudgetaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign${transaction.amount.toStringAsFixed(2)} EGP',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// ==========================================================
/// EXPORT BUTTONS + METRICS + PRESETS + EXPORT HISTORY
/// ==========================================================
class _ExportButtons extends StatelessWidget {
  final bool isExporting;

  const _ExportButtons({required this.isExporting});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Export as PDF',
          onPressed: isExporting
              ? null
              : () => cubit.generateAndExport(asPdf: true),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
        ),
        IconButton(
          tooltip: 'Export as CSV',
          onPressed: isExporting
              ? null
              : () => cubit.generateAndExport(asPdf: false),
          icon: const Icon(Icons.table_chart_rounded, size: 20),
        ),
        if (isExporting)
          const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

class _MetricsHint extends StatelessWidget {
  final DashboardLoaded state;

  const _MetricsHint({required this.state});

  @override
  Widget build(BuildContext context) {
    final metrics = state.performanceMetrics ?? {};
    final lastRefreshMs = metrics['lastRefreshMs'];
    final lastReportMs = metrics['lastReportMs'];

    final parts = <String>[];
    if (state.lastReport != null) {
      parts.add(
        'Last report: ${state.lastReport!.generatedAt.toLocal().toString().split(".").first}',
      );
    }
    if (lastRefreshMs != null) {
      parts.add('Refresh ~ ${lastRefreshMs}ms');
    }
    if (lastReportMs != null) {
      parts.add('Report ~ ${lastReportMs}ms');
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join('  •  '),
      style: const TextStyle(fontSize: 11, color: BudgetaColors.textMuted),
    );
  }
}

/// ====== UPDATED PRESETS UI =================================================
class _PresetsSection extends StatelessWidget {
  final List<dash_repo.DashboardPreset> presets;
  final VoidCallback onSavePreset;
  final void Function(dash_repo.DashboardPreset) onApplyPreset;

  const _PresetsSection({
    required this.presets,
    required this.onSavePreset,
    required this.onApplyPreset,
  });

  @override
  Widget build(BuildContext context) {
    final hasPresets = presets.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Dashboard presets',
              style: TextStyle(
                color: BudgetaColors.deep,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onSavePreset,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Save current view'),
              style: TextButton.styleFrom(
                foregroundColor: BudgetaColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (!hasPresets)
          const Text(
            'No presets yet. Save this filter and layout for later.',
            style: TextStyle(fontSize: 12, color: BudgetaColors.textMuted),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final p in presets)
                _PresetChip(label: p.name, onTap: () => onApplyPreset(p)),
            ],
          ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: BudgetaColors.accentLight.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: BudgetaColors.accentLight.withValues(alpha: 0.9),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timeline_rounded,
              size: 16,
              color: BudgetaColors.deep,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: BudgetaColors.deep,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ====== EXPORT HISTORY UI ==================================================
class _ExportHistorySection extends StatelessWidget {
  final List<dash_repo.SpendingReport> history;

  const _ExportHistorySection({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = history.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export history',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            for (final r in items)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BudgetaColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file_rounded,
                      size: 18,
                      color: BudgetaColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: const TextStyle(
                              color: BudgetaColors.deep,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.generatedAt.toLocal().toString().split('.').first,
                            style: const TextStyle(
                              fontSize: 11,
                              color: BudgetaColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// ==========================================================
/// HELPERS
/// ==========================================================
Future<String?> _askPresetNameDialog(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: 0,
        ),
        contentPadding: const EdgeInsets.only(
          top: 10,
          left: 24,
          right: 24,
          bottom: 20,
        ),
        title: const Text(
          'Save dashboard preset',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Preset name',
                filled: true,
                fillColor: BudgetaColors.accentLight.withValues(alpha: 0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: BudgetaColors.accentLight.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: BudgetaColors.accentLight.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: BudgetaColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: BudgetaColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BudgetaColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(ctx).pop(controller.text);
            },
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      );
    },
  );
}

/// ==========================================================
/// TRANSACTION LIST BOTTOM SHEET
/// ==========================================================
Future<void> _showCategoryTransactionsSheet({
  required BuildContext context,
  required String title,
  required List<Transaction> transactions,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final sheetHeight = MediaQuery.of(ctx).size.height * 0.75;

      return Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: BudgetaColors.accentLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header / Title section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: BudgetaColors.deep,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transactions.length} transaction(s)',
                      style: TextStyle(
                        color: BudgetaColors.textMuted.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),
              const Divider(color: BudgetaColors.accentLight, height: 1),
              const SizedBox(height: 4),

              // Transaction list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: transactions.length,
                  itemBuilder: (_, i) {
                    final t = transactions[i];
                    final isExpense = t.type == TransactionType.expense;
                    final signedAmount = isExpense ? -t.amount : t.amount;
                    final date = t.date.toLocal().toString().split(' ').first;

                    return _TransactionListItem(
                      note: t.note ?? 'No note',
                      date: date,
                      amount: signedAmount,
                      currency: 'EGP',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _TransactionListItem extends StatelessWidget {
  final String note;
  final String date;
  final double amount;
  final String currency;

  const _TransactionListItem({
    required this.note,
    required this.date,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNegative = amount < 0;
    final Color amountColor = isNegative
        ? BudgetaColors.primary
        : BudgetaColors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note,
                style: const TextStyle(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: TextStyle(
                  color: BudgetaColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            '${amount.toStringAsFixed(2)} $currency',
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
