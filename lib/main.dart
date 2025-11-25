import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Theme
import 'config/theme/app_theme.dart';

// Navigation
import 'modules/home/home_nav.dart';

// Repositories
import 'data/repositories/transaction_repo.dart';
import 'data/repositories/goals_repo.dart';
import 'data/repositories/dashboard_repo.dart';
import 'data/repositories/community_repo.dart';

// Controllers
import 'modules/expense/expense_controller.dart';
import 'modules/savings/goal_controller.dart';
import 'modules/dashboard/dashboard_controller.dart';
import 'modules/community/community_controller.dart';
import 'modules/ai_coach/ai_coach_controller.dart';
import 'modules/gamification/gamification_controller.dart';

// Auth
import 'state/auth_provider.dart';

// Onboarding
import 'state/onboarding_state.dart';
import 'modules/onboarding/onboarding_page.dart';

// Login
import 'modules/auth/login_page.dart';

void main() {
  runApp(const BudgetaApp());
}

class BudgetaApp extends StatelessWidget {
  const BudgetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Onboarding
        ChangeNotifierProvider(create: (_) => OnboardingState()),

        // Auth Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Repositories
        Provider(create: (_) => TransactionRepository()),
        Provider(create: (_) => GoalsRepository()),
        Provider(create: (_) => CommunityRepository()),
        ProxyProvider<TransactionRepository, DashboardRepository>(
          update: (_, transactionRepo, __) =>
              DashboardRepository(transactionRepo),
        ),

        // Controllers
        ChangeNotifierProxyProvider<TransactionRepository, ExpenseController>(
          create: (context) =>
              ExpenseController(Provider.of<TransactionRepository>(context, listen: false)),
          update: (_, repo, __) => ExpenseController(repo),
        ),

        ChangeNotifierProxyProvider<GoalsRepository, GoalController>(
          create: (context) =>
              GoalController(Provider.of<GoalsRepository>(context, listen: false)),
          update: (_, repo, __) => GoalController(repo),
        ),

        ChangeNotifierProxyProvider<DashboardRepository, DashboardController>(
          create: (context) =>
              DashboardController(Provider.of<DashboardRepository>(context, listen: false)),
          update: (_, repo, __) => DashboardController(repo),
        ),

        ChangeNotifierProxyProvider<CommunityRepository, CommunityController>(
          create: (context) =>
              CommunityController(Provider.of<CommunityRepository>(context, listen: false)),
          update: (_, repo, __) => CommunityController(repo),
        ),

        ChangeNotifierProvider(create: (_) => AiCoachController()),
        ChangeNotifierProvider(create: (_) => GamificationController()),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Budgeta",
        theme: AppTheme.lightTheme,

        // APP START LOGIC
        home: Consumer2<OnboardingState, AuthProvider>(
          builder: (context, onboarding, auth, _) {

            // 🔄 1) Wait for onboarding state to load from prefs
            if (onboarding.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // 🎬 2) First time user → Show onboarding
            if (!onboarding.isDone) {
              return const OnboardingPage();
            }

            // 🔐 3) Onboarding done but user not logged in → Login
            if (!auth.isLoggedIn) {
              return const LoginPage();
            }

            // 🏠 4) Logged in → Go to App
            return const HomeNav();
          },
        ),
      ),
    );
  }
}
