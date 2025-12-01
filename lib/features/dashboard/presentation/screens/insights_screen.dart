// lib/features/dashboard/presentation/screens/insights_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../shared/bottom_nav.dart';
import '../../state/dashboard_cubit.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        title: const Text('Insights'),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 1),
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
            onRefresh: () =>
                context.read<DashboardCubit>().refreshPipelines(),
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              children: [
                if (loaded.insights.isEmpty &&
                    loaded.budgetIssues.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        'No insights yet.\nKeep using Budgeta and we’ll start spotting trends for you 💕',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else ...[
                  Text(
                    'Personalized insights',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  ...loaded.insights.map(
                    (i) => Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.lightbulb_outline,
                          color: BudgetaColors.deep,
                        ),
                        title: Text(i.title),
                        subtitle: Text(i.description),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (loaded.budgetIssues.isNotEmpty) ...[
                    Text(
                      'Budget checks',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    ...loaded.budgetIssues.map(
                      (b) => Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
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
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
