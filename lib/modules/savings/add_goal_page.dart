import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import 'goal_controller.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GoalController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Goal", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppTextField(
              label: "Goal Title",
              controller: titleController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: "Target Amount",
              controller: amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: "Create Goal",
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (titleController.text.isEmpty || amount == null) return;

                controller.addGoal(titleController.text, amount);

                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
