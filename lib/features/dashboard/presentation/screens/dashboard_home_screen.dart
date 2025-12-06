import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../app/router.dart';
import '../../../../shared/bottom_nav.dart';

// State
import '../../state/dashboard_cubit.dart';
import '../../../../features/tracking/state/tracking_cubit.dart';

// Models
import '../../../../core/models/transaction.dart';
import '../../../../core/models/dashboard_view.dart';
import '../../../../core/models/insight.dart';
import '../../data/dashboard_repository.dart' as dash_repo;

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
                            cubit.changeFilter(f);
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

                        const SizedBox(height: 12),

                        // ---------------------------
                        //  MAIN CONTENT
                        // ---------------------------
                        _QuickStatsRow(view: view),
                        const SizedBox(height: 20),

                        // Smart Insights
                        InsightsSection(insights: state.insights),
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

                        // Budget health
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
        Navigator.pushNamed(
          context,
          AppRoutes.addTransaction,
          arguments: TransactionType.expense,
        );
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFF4F8B), Color(0xFF9A0E3A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
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
        // Dark at the very top → lighter near the card
        gradient: LinearGradient(
          colors: [
            Color(0xFF9A0E3A), // deep top
            Color(0xFFFF4F8B), // lighter bottom
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting + circular sparkles button (decorative only)
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
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
            ],
          ),

          const SizedBox(height: 20),

          // Main balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
                    // income – trending up (green)
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 16,
                          color: Colors.green.shade600,
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
                    // expenses – trending down (pink)
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
                icon: Icons.attach_money_rounded,
                title: '${totalThisPeriod.toStringAsFixed(2)} EGP',
                subtitle: 'This Month',
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
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: BudgetaColors.accentLight.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BudgetaColors.accentLight.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: BudgetaColors.primary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: BudgetaColors.textMuted,
                  fontSize: 11,
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
        Row(
          children: const [
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
    final color = isExpense ? BudgetaColors.primary : Colors.green.shade600;

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
          // circular icon like design
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isExpense
                  ? BudgetaColors.accentLight.withValues(alpha: 0.5)
                  : Colors.green.withOpacity(0.15),
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
/// EXPORT BUTTONS + METRICS + PRESETS
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
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (presets.isEmpty)
          const Text(
            'No presets yet. Save this filter and layout for later.',
            style: TextStyle(fontSize: 12, color: BudgetaColors.textMuted),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final p in presets)
                ActionChip(
                  label: Text(p.name),
                  avatar: const Icon(
                    Icons.timeline_rounded,
                    size: 16,
                    color: BudgetaColors.deep,
                  ),
                  onPressed: () => onApplyPreset(p),
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
        title: const Text('Save dashboard preset'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Preset name',
            hintText: 'e.g. Exam month view',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(controller.text);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Future<void> _showCategoryTransactionsSheet({
  required BuildContext context,
  required String title,
  required List<Transaction> transactions,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: BudgetaColors.deep,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${transactions.length} transaction(s)',
                style: const TextStyle(
                  fontSize: 12,
                  color: BudgetaColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (_, i) {
                    final t = transactions[i];
                    final isExpense = t.type == TransactionType.expense;
                    final sign = isExpense ? '-' : '+';
                    final color = isExpense
                        ? BudgetaColors.primary
                        : Colors.green.shade600;
                    final date = t.date.toLocal().toString().split(' ').first;

                    return ListTile(
                      dense: true,
                      title: Text(
                        t.note ?? 'No note',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: BudgetaColors.deep,
                        ),
                      ),
                      subtitle: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: BudgetaColors.textMuted,
                        ),
                      ),
                      trailing: Text(
                        '$sign${t.amount.toStringAsFixed(2)} EGP',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
