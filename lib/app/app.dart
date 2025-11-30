import 'package:flutter/material.dart';

class BudgetaApp extends StatelessWidget {
  const BudgetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budgeta',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('Budgeta App Structure Ready'),
        ),
      ),
    );
  }
}
