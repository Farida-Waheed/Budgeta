// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';

// 🔹 Tracking
import 'features/tracking/data/in_memory_tracking_repository.dart';
import 'features/tracking/state/tracking_cubit.dart';

// 🔹 Dashboard
import 'features/dashboard/data/in_memory_dashboard_repository.dart';
import 'features/dashboard/state/dashboard_cubit.dart';

// 🔹 Goals
import 'features/goals/data/in_memory_goals_repository.dart';
import 'features/goals/state/goals_cubit.dart';

// 🔹 Gamification
import 'features/gamification/data/in_memory_gamification_repository.dart';
import 'features/gamification/state/gamification_cubit.dart';

// 🔹 Community
import 'features/community/data/community_repository_impl.dart';
import 'features/community/state/community_cubit.dart';

// 🔹 Coach
import 'features/coach/data/in_memory_coach_repository.dart';
import 'features/coach/state/coach_cubit.dart';

// If you have firebase_options.dart, you can import it and uncomment below.
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // -----------------------------
  //  Shared in-memory repositories
  // -----------------------------
  const userId = 'demo-user';

  final trackingRepo = InMemoryTrackingRepository();

  final dashboardRepo = InMemoryDashboardRepository(
    trackingRepository: trackingRepo,
  );

  final goalsRepo = InMemoryGoalsRepository();

  final gamificationRepo = InMemoryGamificationRepository();

  final communityRepo = InMemoryCommunityRepository();

  final coachRepo = InMemoryCoachRepository(trackingRepository: trackingRepo);

  runApp(
    MultiBlocProvider(
      providers: [
        // 💸 Expense & Income Tracking
        BlocProvider<TrackingCubit>(
          create: (_) =>
              TrackingCubit(repository: trackingRepo, userId: userId)
                ..loadTransactions(),
        ),

        // 📊 Dashboard & Analytics
        BlocProvider<DashboardCubit>(
          create: (_) =>
              DashboardCubit(repository: dashboardRepo, userId: userId)
                ..loadDashboard(),
        ),

        // 🎯 Savings Goals
        BlocProvider<GoalsCubit>(
          create: (_) =>
              GoalsCubit(repository: goalsRepo, userId: userId)..loadGoals(),
        ),

        // 🏆 Gamification (challenges + badges)
        BlocProvider<GamificationCubit>(
          create: (_) =>
              GamificationCubit(gamificationRepo, userId: userId)..load(),
        ),

        // 👭 Community & Social
        BlocProvider<CommunityCubit>(
          create: (_) => CommunityCubit(
            repository: communityRepo,
            userId: userId,
            userName: 'You', // later: real profile name
          )..load(),
        ),

        // 🧠 Coach
        BlocProvider<CoachCubit>(
          create: (_) =>
              CoachCubit(repository: coachRepo, userId: userId)
                ..loadCoachHome(),
        ),
      ],
      child: const BudgetaApp(),
    ),
  );
}
