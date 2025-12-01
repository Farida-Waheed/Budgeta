// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'router.dart';
import 'theme.dart';
import '../features/tracking/data/tracking_repository.dart';
import '../features/tracking/data/in_memory_tracking_repository.dart';

class BudgetaApp extends StatelessWidget {
  const BudgetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide ONE shared TrackingRepository instance for the whole app
    return RepositoryProvider<TrackingRepository>(
      create: (_) => InMemoryTrackingRepository(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Budgeta',
        theme: BudgetaTheme.lightTheme,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: AppRoutes.home,
      ),
    );
  }
}
