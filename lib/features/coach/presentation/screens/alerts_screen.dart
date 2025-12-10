// lib/features/coach/presentation/screens/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/models/alert.dart';
import '../../../../shared/bottom_nav.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Alert> alerts = [
      Alert(
        id: 'a1',
        userId: 'demo',
        type: AlertType.overspent,
        title: 'You overspent on Dining Out 🍕',
        message:
            'You are 30% above your usual dining budget this week. Try one no-delivery day to rebalance.',
        createdAt: DateTime.now(),
      ),
      Alert(
        id: 'a2',
        userId: 'demo',
        type: AlertType.upcomingBill,
        title: 'Internet bill due in 3 days 📅',
        message: 'Your 450 EGP internet bill is coming up on Monday.',
        createdAt: DateTime.now(),
      ),
      Alert(
        id: 'a3',
        userId: 'demo',
        type: AlertType.goalOffTrack,
        title: 'Dream Vacation is slightly off-track 🏖️',
        message:
            'You skipped saving last week. Add 200 EGP extra this week to stay on schedule.',
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const _AlertsHeader(), // ⬅️ bigger header card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MagicSectionTitle('Recent alerts'),
                    const SizedBox(height: 16),
                    for (final alert in alerts) _AlertTile(alert: alert),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 3),
    );
  }
}

/// Bigger gradient header for Alerts (matches other subsystems)
class _AlertsHeader extends StatelessWidget {
  const _AlertsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9A0E3A), Color(0xFFFF4F8B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 26, 12, 30),
      constraints: const BoxConstraints(minHeight: 110),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Alerts 🔔',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // was 20
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6), // was 4
                Text(
                  'Gentle nudges before things slip.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14, // was 13
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final Alert alert;

  const _AlertTile({required this.alert});

  IconData _iconForType(AlertType type) {
    switch (type) {
      case AlertType.overspent:
        return FeatherIcons.trendingUp;
      case AlertType.upcomingBill:
        return FeatherIcons.calendar;
      case AlertType.lowBalance:
        return FeatherIcons.alertTriangle;
      case AlertType.goalOffTrack:
        return FeatherIcons.flag;
    }
  }

  Color _bgForType(AlertType type) {
    switch (type) {
      case AlertType.overspent:
        return const Color(0xFFFFEBEE);
      case AlertType.upcomingBill:
        return const Color(0xFFFFF3CD);
      case AlertType.lowBalance:
        return const Color(0xFFE3F2FD);
      case AlertType.goalOffTrack:
        return const Color(0xFFFFF0F4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagicCard(
      borderRadius: 18,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _bgForType(alert.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForType(alert.type),
              size: 20,
              color: BudgetaColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BudgetaColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
