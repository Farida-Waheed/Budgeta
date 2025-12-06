// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'router.dart';
import 'theme.dart';

// Tracking
import '../features/tracking/data/tracking_repository.dart';
import '../features/tracking/data/in_memory_tracking_repository.dart';

class BudgetaApp extends StatelessWidget {
  const BudgetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TrackingRepository>(
      // thanks to the singleton pattern, this is the same instance
      // used everywhere in the app
      create: (_) => InMemoryTrackingRepository(),

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Budgeta',

        theme: BudgetaTheme.lightTheme,
        darkTheme: BudgetaTheme.darkTheme,
        themeMode: ThemeMode.light,

        // use the new router
        onGenerateRoute: AppRouter.onGenerateRoute,

        // first screen = hero / welcome (DashboardOverviewScreen)
        initialRoute: AppRoutes.home,
      ),
    );
  }
}
