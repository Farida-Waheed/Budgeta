import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/colors.dart';
//import '../../widgets/loading_indicator.dart';
import 'goal_controller.dart';
import 'add_goal_page.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GoalController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Savings Goals", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.red,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGoalPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: controller.goals.isEmpty
          ? const Center(
              child: Text(
                "No goals yet.\nAdd your first goal!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: controller.goals.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, index) {
                final goal = controller.goals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: goal.progress,
                        backgroundColor: Colors.white,
                        color: AppColors.red,
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          controller.updateGoal(goal.id, 50); // add money
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pink,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Add 50 EGP"),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
