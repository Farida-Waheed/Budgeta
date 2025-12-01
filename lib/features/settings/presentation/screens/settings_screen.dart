import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // For now these are local-only. Later we can persist them with a repository.
  bool _notificationsEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _smartCategoriesEnabled = true;
  bool _darkMode = false; // placeholder
  String _currency = 'EGP';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- GENERAL ---
          Text(
            'General',
            style: theme.textTheme.labelLarge?.copyWith(
              color: BudgetaColors.deep,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Currency'),
                  subtitle: Text(_currency),
                  trailing: DropdownButton<String>(
                    value: _currency,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'EGP',
                        child: Text('EGP – Egyptian pound'),
                      ),
                      DropdownMenuItem(
                        value: 'USD',
                        child: Text('USD – US dollar'),
                      ),
                      DropdownMenuItem(
                        value: 'EUR',
                        child: Text('EUR – Euro'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _currency = value);
                    },
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(_language),
                  trailing: DropdownButton<String>(
                    value: _language,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'English',
                        child: Text('English'),
                      ),
                      DropdownMenuItem(
                        value: 'Arabic',
                        child: Text('Arabic'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _language = value);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- NOTIFICATIONS ---
          Text(
            'Notifications',
            style: theme.textTheme.labelLarge?.copyWith(
              color: BudgetaColors.deep,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('App notifications'),
                  subtitle:
                      const Text('Allow Budgeta to send helpful reminders'),
                  value: _notificationsEnabled,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                const Divider(height: 0),
                SwitchListTile(
                  title: const Text('Budget alerts'),
                  subtitle: const Text(
                      'Warn me when I\'m close to overspending this period'),
                  value: _budgetAlertsEnabled,
                  onChanged: (value) =>
                      setState(() => _budgetAlertsEnabled = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- TRACKING / SMART FEATURES ---
          Text(
            'Tracking',
            style: theme.textTheme.labelLarge?.copyWith(
              color: BudgetaColors.deep,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Smart categories'),
                  subtitle: const Text(
                      'Let Budgeta suggest categories based on your history'),
                  value: _smartCategoriesEnabled,
                  onChanged: (value) =>
                      setState(() => _smartCategoriesEnabled = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- APPEARANCE ---
          Text(
            'Appearance',
            style: theme.textTheme.labelLarge?.copyWith(
              color: BudgetaColors.deep,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SwitchListTile(
              title: const Text('Dark mode'),
              subtitle:
                  const Text('Coming soon – for now this is a demo switch'),
              value: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
            ),
          ),

          const SizedBox(height: 24),

          // --- DATA MANAGEMENT (demo) ---
          Text(
            'Data & privacy',
            style: theme.textTheme.labelLarge?.copyWith(
              color: BudgetaColors.deep,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Clear demo data'),
                  subtitle: const Text(
                      'Reset transactions & dashboard to a clean state'),
                  onTap: () {
                    // TODO: hook to a real repository method later
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Demo only – connect to data clearing logic later.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
