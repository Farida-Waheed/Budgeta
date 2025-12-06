// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';

// Tracking
import 'features/tracking/data/in_memory_tracking_repository.dart';
import 'features/tracking/state/tracking_cubit.dart';

// Dashboard
import 'features/dashboard/data/in_memory_dashboard_repository.dart';
import 'features/dashboard/state/dashboard_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Shared in-memory repositories (demo setup)
  final trackingRepo = InMemoryTrackingRepository();
  final dashboardRepo = InMemoryDashboardRepository(
    trackingRepository: trackingRepo,
  );

  const userId = 'demo-user';

  runApp(
    MultiBlocProvider(
      providers: [
        // Expense & Income Tracking
        BlocProvider<TrackingCubit>(
          create: (_) => TrackingCubit(
            repository: trackingRepo,
            userId: userId,
          )..loadTransactions(),
        ),

        // Dashboard & Analytics
        BlocProvider<DashboardCubit>(
          create: (_) => DashboardCubit(
            repository: dashboardRepo,
            userId: userId,
          )..loadDashboard(), // now allowed (optional param)
        ),
      ],
      child: const BudgetaApp(),
    ),
  );
}
