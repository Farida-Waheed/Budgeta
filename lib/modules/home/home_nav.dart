import 'package:flutter/material.dart';

// Pages
import '../dashboard/dashboard_page.dart';
import '../expense/expense_page.dart';
import '../savings/goals_page.dart';
import '../community/community_page.dart';
import '../ai_coach/coach_page.dart';
import '../gamification/gamification_page.dart';

// Theme
import '../../config/theme/colors.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    DashboardPage(),     // 0
    ExpensePage(),       // 1
    GoalsPage(),         // 2
    CommunityPage(),     // 3
    CoachPage(),         // 4
    GamificationPage(),  // 5 (Rewards tab)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.red,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Expenses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: "Goals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: "Coach",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: "Rewards",
          ),
        ],
      ),
    );
  }
}
