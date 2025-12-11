// lib/features/coach/presentation/screens/coach_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../../../app/theme.dart';
import '../../../../shared/bottom_nav.dart';

class CoachSettingsScreen extends StatefulWidget {
  const CoachSettingsScreen({super.key});

  @override
  State<CoachSettingsScreen> createState() => _CoachSettingsScreenState();
}

class _CoachSettingsScreenState extends State<CoachSettingsScreen> {
  bool _dailyTips = true;
  bool _weeklySummary = true;
  bool _overspendAlerts = true;
  bool _goalNudges = true;
  double _tone = 0.6; // 0 = super soft, 1 = tough love

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: Column(
        children: [
          // 🌈 Big gradient header, same style as other coach screens
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 44, // gradient goes behind status bar
              bottom: 26,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [BudgetaColors.primary, BudgetaColors.deep],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach Settings ⚙️',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tell your coach how to support you.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // 📋 Content under SafeArea (top: false so gradient stays visible)
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(FeatherIcons.sun),
                    title: const Text('Daily tips'),
                    subtitle: const Text(
                      'Short morning nudges to stay mindful.',
                    ),
                    value: _dailyTips,
                    onChanged: (v) => setState(() => _dailyTips = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(FeatherIcons.calendar),
                    title: const Text('Weekly summary'),
                    subtitle: const Text('A wrap-up of your wins & trends.'),
                    value: _weeklySummary,
                    onChanged: (v) => setState(() => _weeklySummary = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(FeatherIcons.alertTriangle),
                    title: const Text('Overspend alerts'),
                    subtitle: const Text('Ping you when a category jumps.'),
                    value: _overspendAlerts,
                    onChanged: (v) => setState(() => _overspendAlerts = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(FeatherIcons.trendingUp),
                    title: const Text('Goal nudges'),
                    subtitle: const Text(
                      'Suggestions to keep savings on-track.',
                    ),
                    value: _goalNudges,
                    onChanged: (v) => setState(() => _goalNudges = v),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tone of voice',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tone < 0.33
                        ? 'Extra gentle & encouraging.'
                        : _tone < 0.66
                        ? 'Balanced: kind but honest.'
                        : 'Tough love: very direct.',
                    style: const TextStyle(
                      color: BudgetaColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  Slider(
                    value: _tone,
                    onChanged: (v) => setState(() => _tone = v),
                    activeColor: BudgetaColors.primary,
                    inactiveColor: BudgetaColors.cardBorder.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 3),
    );
  }
}
