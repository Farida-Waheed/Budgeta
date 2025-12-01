// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How to use Budgeta'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Dashboard: See your income, expenses and alerts.'),
            SizedBox(height: 4),
            Text('• Tracking: Add expenses, income and categories.'),
            SizedBox(height: 4),
            Text('• Goals & Challenges: Plan savings and stay motivated.'),
            SizedBox(height: 4),
            Text('• Community: Share wins and get inspired.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        elevation: 0,
        centerTitle: true,
        title: const Text('Budgeta'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          // 🔹 Use your custom app icon in the AppBar
          child: Image.asset(
            'assets/icons/app_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              // TODO: navigate to profile screen later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile coming soon.'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Tips',
            onPressed: _showTipsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
                
              // 🔹 Big circular logo in the center using your icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/app_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
                
              const SizedBox(height: 24),
                
              // Welcome message
              Text(
                'Welcome to Budgeta 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your personal money coach to track spending, save for goals, '
                'and stay on top of your budget.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: BudgetaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
                
              const SizedBox(height: 32),
                
              // Quick actions card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dashboard_customize_outlined),
                        title: const Text('Open my dashboard'),
                        subtitle: const Text(
                          'See today’s overview of income, expenses & alerts.',
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.dashboard);
                        },
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text('Add a transaction'),
                        subtitle: const Text(
                          'Log an expense or income to keep your budget fresh.',
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                              context, AppRoutes.addTransaction);
                        },
                      ),
                    ],
                  ),
                ),
              ),
                
              const SizedBox(height: 32),
                
              // Tips button (second entry point)
              TextButton.icon(
                onPressed: _showTipsDialog,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Show tips for using Budgeta'),
              ),
                
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
