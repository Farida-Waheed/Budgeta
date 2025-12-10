// lib/features/coach/presentation/screens/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/models/alert.dart';
import '../../../../shared/bottom_nav.dart';
import '../../state/coach_cubit.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const MagicGradientHeader(
              title: 'Smart Alerts 🔔',
              subtitle: 'Gentle nudges before things slip.',
            ),
            Expanded(
              child: BlocBuilder<CoachCubit, CoachState>(
                builder: (context, state) {
                  if (state is CoachInitial || state is CoachLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CoachError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Couldn\'t load alerts.\n${state.message}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final loaded = state as CoachLoaded;
                  final alerts = loaded.alerts;

                  if (alerts.isEmpty) {
                    return const Center(
                      child: Text('No active alerts right now ✨'),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MagicSectionTitle('Recent alerts'),
                        const SizedBox(height: 16),
                        for (final alert in alerts)
                          Dismissible(
                            key: ValueKey(alert.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              context.read<CoachCubit>().dismissAlert(alert.id);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              color: Colors.red.withValues(alpha: 0.15),
                              child: const Icon(
                                FeatherIcons.check,
                                color: Colors.red,
                              ),
                            ),
                            child: _AlertTile(alert: alert),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 3),
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
