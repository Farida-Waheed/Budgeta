// lib/app/router.dart
import 'package:flutter/material.dart';

// HERO / WELCOME (Transform your money journey...)
import '../features/dashboard/presentation/screens/dashboard_overview_screen.dart';

// MAIN DASHBOARD (Hello, Beautiful! + balance + lists)
import '../features/dashboard/presentation/screens/dashboard_home_screen.dart';

// TRACKING
import '../features/tracking/presentation/screens/transactions_list_screen.dart';
import '../features/tracking/presentation/screens/add_transaction_screen.dart';
import '../features/tracking/presentation/screens/edit_transaction_screen.dart';
import '../features/tracking/presentation/screens/recurring_transactions_screen.dart';

// COACH / GOALS / COMMUNITY
import '../features/coach/presentation/screens/coach_home_screen.dart';
import '../features/goals/presentation/screens/goals_home_screen.dart';
import '../features/community/presentation/screens/community_feed_screen.dart';

// ⭐ GAMIFICATION – CHALLENGES
import '../features/gamification/presentation/screens/challenges_screen.dart';

// SETTINGS
import '../features/settings/presentation/screens/settings_screen.dart';

// 🔐 AUTH SCREENS
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/signin_screen.dart';

// MODELS
import '../core/models/transaction.dart';

/// ----------------------
/// ROUTE NAMES
/// ----------------------
class AppRoutes {
  /// First screen when app launches → hero “Transform your money journey…”
  static const String home = '/';

  /// Main dashboard (Hello, Beautiful! + balance + stats)
  static const String dashboard = '/dashboard';

  /// Tracking / transactions
  static const String tracking = '/tracking';
  static const String transactions = '/transactions'; // alias if needed
  static const String addTransaction = '/tracking/add';
  static const String editTransaction = '/tracking/edit';
  static const String recurring = '/tracking/recurring';

  /// Other subsystems
  static const String goals = '/goals';
  static const String coach = '/coach';
  static const String challenges = '/challenges';
  static const String community = '/community';

  /// Settings
  static const String settings = '/settings';

  /// 🔐 AUTH
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String forgotPassword = '/auth/forgot-password';
  static const String phoneSignin = '/auth/phone-signin';
}

/// ----------------------
/// APP ROUTER
/// ----------------------
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // -------------------
      //   HOME → HERO SCREEN
      // -------------------
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const DashboardOverviewScreen(),
          settings: settings,
        );

      // -------------------
      //   DASHBOARD
      // -------------------
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardHomeScreen(),
          settings: settings,
        );

      // -------------------
      //   TRACKING / TRANSACTIONS
      // -------------------
      case AppRoutes.tracking:
      case AppRoutes.transactions:
        return MaterialPageRoute(
          builder: (_) => const TransactionsListScreen(),
          settings: settings,
        );

      case AppRoutes.addTransaction:
        TransactionType? preselected;
        final args = settings.arguments;
        if (args is TransactionType) {
          preselected = args;
        } else if (args is Map && args['type'] is TransactionType) {
          preselected = args['type'] as TransactionType;
        }

        return MaterialPageRoute(
          builder: (_) => AddTransactionScreen(preselectedType: preselected),
          settings: settings,
        );

      case AppRoutes.editTransaction:
        final args = settings.arguments;
        if (args is! Transaction) {
          return _errorRoute('EditTransactionScreen needs a Transaction.');
        }
        return MaterialPageRoute(
          builder: (_) => EditTransactionScreen(transaction: args),
          settings: settings,
        );

      case AppRoutes.recurring:
        return MaterialPageRoute(
          builder: (_) => const RecurringTransactionsScreen(),
          settings: settings,
        );

      // -------------------
      //   GOALS / COACH / COMMUNITY / CHALLENGES
      // -------------------
      case AppRoutes.goals:
        return MaterialPageRoute(
          builder: (_) => const GoalsHomeScreen(),
          settings: settings,
        );

      case AppRoutes.coach:
        return MaterialPageRoute(
          builder: (_) => const CoachHomeScreen(),
          settings: settings,
        );

      case AppRoutes.community:
        return MaterialPageRoute(
          builder: (_) => const CommunityFeedScreen(),
          settings: settings,
        );

      case AppRoutes.challenges:
        return MaterialPageRoute(
          builder: (_) => const ChallengesScreen(),
          settings: settings,
        );

      // -------------------
      //   🔐 AUTH SCREENS
      // -------------------
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LogInScreen(),
          settings: settings,
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.phoneSignin:
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
          settings: settings,
        );

      // -------------------
      //   DEFAULT → HERO
      // -------------------
      default:
        return MaterialPageRoute(
          builder: (_) => const DashboardOverviewScreen(),
          settings: settings,
        );
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Routing error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
