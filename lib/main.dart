import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'config/theme/app_theme.dart';

void main() {
  runApp(const BudgetaApp());
}

class BudgetaApp extends StatelessWidget {
  const BudgetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budgeta',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
