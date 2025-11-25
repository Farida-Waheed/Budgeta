import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme/colors.dart';
import '../profile/profile_page.dart';
import 'dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DashboardController>(context);

    final income = controller.monthlyIncome;
    final expense = controller.monthlyExpense;
    final remaining = income - expense;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _summaryCard(
                    title: "Income",
                    value: income.toStringAsFixed(2),
                    color: AppColors.pink,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    title: "Expenses",
                    value: expense.toStringAsFixed(2),
                    color: AppColors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    title: "Remaining",
                    value: remaining.toStringAsFixed(2),
                    color: remaining >= 0 ? AppColors.rose : Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              "Spending by Category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: controller.categoryBreakdown.isEmpty
                  ? const Center(
                      child: Text(
                        "No expenses yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: controller.categoryBreakdown.length,
                      itemBuilder: (context, i) {
                        final entry =
                            controller.categoryBreakdown.entries.elementAt(i);
                        return ListTile(
                          title: Text(entry.key),
                          trailing: Text(
                            entry.value.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        // height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
