import 'package:flutter/material.dart';

class AddGoalPage extends StatelessWidget {
  const AddGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Goal")),
      body: const Center(child: Text("Goal Form")),
    );
  }
}
