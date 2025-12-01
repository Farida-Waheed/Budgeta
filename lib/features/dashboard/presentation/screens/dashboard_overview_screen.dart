import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../app/router.dart';
import '../../../../shared/bottom_nav.dart';
import '../../data/dashboard_repository.dart' as dash_repo;
import '../../state/dashboard_cubit.dart';
import '../widgets/kpi_header.dart';
import '../widgets/spending_chart.dart';
import '../widgets/time_filter_bar.dart';
import '../../../../core/models/transaction.dart';

class DashboardOverviewScreen extends StatelessWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_vert),
            tooltip: 'Compare with previous period',
            onPressed: () =>
                context.read<DashboardCubit>().compareWithPrevious(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) async {
              final cubit = context.read<DashboardCubit>();
              if (value == 'export_pdf') {
                await cubit.generateAndExport(asPdf: true);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report exported as PDF')),
                  );
                }
              } else if (value == 'export_csv') {
                await cubit.generateAndExport(asPdf: false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report exported as CSV')),
                  );
                }
              } else if (value == 'save_preset') {
                _showSavePresetDialog(context, cubit);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'save_preset',
                child: Text('Save dashboard preset'),
              ),
              PopupMenuItem(
                value: 'export_pdf',
                child: Text('Export report (PDF)'),
              ),
              PopupMenuItem(
                value: 'export_csv',
                child: Text('Export report (CSV)'),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 0),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          final loaded = state as DashboardLoaded;

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().refreshPipelines(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              shrinkWrap: false,
              children: [
                // ---- Filter Dashboard ----
                TimeFilterBar(
                  onFilterChanged: (dash_repo.DashboardFilter f) {
                    context.read<DashboardCubit>().changeFilter(f);
                  },
                ),
                const SizedBox(height: 16),

                // ---- Overview KPIs ----
                KpiHeader(view: loaded.view),
                const SizedBox(height: 16),

                // ---- Category analytics + drill down ----
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SpendingChart(
                      view: loaded.view,
                      onCategoryTap: (categoryId, name) async {
                        final txs = await context
                            .read<DashboardCubit>()
                            .drillDownToCategory(categoryId);
                        // ignore: use_build_context_synchronously
                        _showTransactionsBottomSheet(context, txs, name);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Insights + budget issues ----
                if (loaded.insights.isNotEmpty ||
                    loaded.budgetIssues.isNotEmpty)
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Insights & alerts',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          ...loaded.insights.map(
                            (i) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading:
                                  const Icon(Icons.lightbulb_outline, size: 20),
                              title: Text(i.title),
                              subtitle: Text(i.description),
                            ),
                          ),
                          ...loaded.budgetIssues.map(
                            (b) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                b.severity == 'error'
                                    ? Icons.error_outline
                                    : Icons.warning_amber_rounded,
                                color: b.severity == 'error'
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                              title: Text(b.message),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // ---- Compare periods result (if any) ----
                if (loaded.comparison != null)
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Comparison with previous period',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          Text(
                            'Net: '
                            '${loaded.comparison!.current.net.toStringAsFixed(0)} vs '
                            '${loaded.comparison!.previous.net.toStringAsFixed(0)} EGP',
                          ),
                          Text(
                            'Expenses: '
                            '${loaded.comparison!.current.totalExpenses.toStringAsFixed(0)} vs '
                            '${loaded.comparison!.previous.totalExpenses.toStringAsFixed(0)} EGP',
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // ---- Saved presets ----
                if (loaded.presets.isNotEmpty)
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saved presets',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          ...loaded.presets.map(
                            (p) => ListTile(
                              dense: true,
                              title: Text(p.name),
                              onTap: () =>
                                  context.read<DashboardCubit>().applyPreset(p),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // ---- CTA to add transaction ----
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add expense / income'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BudgetaColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.addTransaction);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ----------------- helpers -----------------

void _showSavePresetDialog(BuildContext context, DashboardCubit cubit) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Save dashboard preset'),
      content: TextField(
        controller: controller,
        decoration:
            const InputDecoration(labelText: 'Preset name (e.g. "Work month")'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (controller.text.trim().isNotEmpty) {
              await cubit.savePreset(controller.text.trim());
            }
            // ignore: use_build_context_synchronously
            Navigator.pop(ctx);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void _showTransactionsBottomSheet(
  BuildContext context,
  List<Transaction> txs,
  String categoryName,
) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Transactions in $categoryName'),
            ),
            const Divider(height: 0),
            if (txs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No transactions yet.'),
              )
            else
              SizedBox(
                height: 320,
                child: ListView.builder(
                  itemCount: txs.length,
                  itemBuilder: (_, index) {
                    final t = txs[index];
                    return ListTile(
                      // ✅ use categoryName as title instead of t.description
                      title: Text(categoryName),
                      subtitle: Text(
                        t.date.toLocal().toString().split(' ').first,
                      ),
                      trailing: Text(
                        '${t.amount.toStringAsFixed(0)} EGP',
                        style: TextStyle(
                          color: t.type == TransactionType.expense
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}
