// lib/app/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Real implemented screens
import '../features/dashboard/presentation/screens/dashboard_overview_screen.dart';
import '../features/tracking/presentation/screens/transactions_list_screen.dart';
import '../features/tracking/presentation/screens/add_transaction_screen.dart';
import '../features/tracking/presentation/screens/recurring_transactions_screen.dart';

// Subsystem screens we still use directly
import '../features/community/presentation/screens/community_feed_screen.dart';

// Shared UI & theme
import '../shared/bottom_nav.dart';
import 'theme.dart';

// For passing preselected type to AddTransactionScreen
import '../core/models/transaction.dart';

// Dashboard wiring
import '../features/dashboard/state/dashboard_cubit.dart';
import '../features/dashboard/data/in_memory_dashboard_repository.dart';
import '../features/dashboard/data/dashboard_repository.dart' as dash_repo;

// Tracking repo implementation (singleton)
import '../features/tracking/data/in_memory_tracking_repository.dart';

// Settings screen
import '../features/settings/presentation/screens/settings_screen.dart';
// NEW: Home screen
import '../features/home/presentation/screens/home_screen.dart';

class AppRoutes {
  // NEW: home is now the root
  static const String home = '/';

  // Dashboard moved to its own path
  static const String dashboard = '/dashboard';

  // Tracking / Transactions
  static const String tracking = '/tracking';
  static const String transactions = '/transactions';

  // Other subsystems
  static const String goals = '/goals';
  static const String coach = '/coach';
  static const String challenges = '/challenges';
  static const String community = '/community';

  // Extra flows
  static const String addTransaction = '/add-transaction';
  static const String recurring = '/recurring';

  // Settings
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // -------------------
      //   HOME
      // -------------------
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      // -------------------
      //   DASHBOARD
      // -------------------
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (context) {
            final trackingRepo = InMemoryTrackingRepository();
            final dashboardRepo = InMemoryDashboardRepository(
              trackingRepository: trackingRepo,
            );

            return BlocProvider<DashboardCubit>(
              create: (_) => DashboardCubit(
                repository: dashboardRepo,
                userId: 'demo-user', // TODO: replace with real user id
              )..loadDashboard(dash_repo.DashboardFilter.currentMonth()),
              child: const DashboardOverviewScreen(),
            );
          },
          settings: settings,
        );

      // -------------------
      //   TRACKING / TRANSACTIONS
      // -------------------
      case tracking:
      case transactions:
        return MaterialPageRoute(
          builder: (_) => const TransactionsListScreen(),
          settings: settings,
        );

      // -------------------
      //   GOALS
      // -------------------
      case goals:
        return MaterialPageRoute(
          builder: (_) => const _GoalsPlaceholderScreen(),
          settings: settings,
        );

      // -------------------
      //   COACH
      // -------------------
      case coach:
        return MaterialPageRoute(
          builder: (_) => const _CoachPlaceholderScreen(),
          settings: settings,
        );

      // -------------------
      //   CHALLENGES
      // -------------------
      case challenges:
        return MaterialPageRoute(
          builder: (_) => const _ChallengesPlaceholderScreen(),
          settings: settings,
        );

      // -------------------
      //   COMMUNITY
      // -------------------
      case community:
        return MaterialPageRoute(
          builder: (_) => const CommunityFeedScreen(),
          settings: settings,
        );

      // -------------------
      //   ADD TRANSACTION
      // -------------------
      case addTransaction:
        TransactionType? preselected;
        final args = settings.arguments;
        if (args is TransactionType) {
          preselected = args;
        }
        return MaterialPageRoute(
          builder: (_) => AddTransactionScreen(
            preselectedType: preselected,
          ),
          settings: settings,
        );

      // -------------------
      //   RECURRING
      // -------------------
      case recurring:
        return MaterialPageRoute(
          builder: (_) => const RecurringTransactionsScreen(),
          settings: settings,
        );

      // -------------------
      //   SETTINGS
      // -------------------
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      // -------------------
      //   DEFAULT → HOME
      // -------------------
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}

/// ---------------------
///   GOALS PLACEHOLDER
/// ---------------------
class _GoalsPlaceholderScreen extends StatelessWidget {
  const _GoalsPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        title: const Text('Goals'),
        centerTitle: true,
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        elevation: 0,
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 2),
      body: const Center(
        child: Text(
          'Goals coming soon...',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

/// ---------------------
///   COACH PLACEHOLDER
/// ---------------------
class _CoachPlaceholderScreen extends StatelessWidget {
  const _CoachPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        title: const Text('Coach'),
        centerTitle: true,
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        elevation: 0,
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 3),
      body: const Center(
        child: Text(
          'Coach feed coming soon...',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

/// -------------------------
///   CHALLENGES PLACEHOLDER
/// -------------------------
class _ChallengesPlaceholderScreen extends StatelessWidget {
  const _ChallengesPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        title: const Text('Challenges'),
        centerTitle: true,
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        elevation: 0,
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 4),
      body: const Center(
        child: Text(
          'Challenges coming soon...',
          style: TextStyle(
            color: BudgetaColors.deep,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
