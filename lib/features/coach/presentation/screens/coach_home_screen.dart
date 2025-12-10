// lib/features/coach/presentation/screens/coach_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme.dart';

// shared widgets
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../shared/bottom_nav.dart';
import '../../../../core/models/alert.dart';

// coach state + repo
import '../../state/coach_cubit.dart';
import '../../data/fake_coach_repository.dart';

// other coach screens
import 'alerts_screen.dart';
import 'coach_feed_screen.dart';
import 'coach_settings_screen.dart';

class CoachHomeScreen extends StatelessWidget {
  const CoachHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide CoachCubit here so this tab is INTERACTIVE
    return BlocProvider(
      create: (_) => CoachCubit(
        repository: FakeCoachRepository(),
        userId: 'demo-user', // later you can pass real user id
      )..loadCoachHome(),
      child: const _CoachHomeView(),
    );
  }
}

class _CoachHomeView extends StatelessWidget {
  const _CoachHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 same top section style as other subsystems
            MagicGradientHeader(
              title: 'Your AI Coach ✨',
              subtitle: 'Personalized tips just for you!',
              trailingIcon: Icons.notifications_none_rounded,
              onTrailingTap: () {
                final cubit = context.read<CoachCubit>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const AlertsScreen(),
                    ),
                  ),
                );
              },
            ),

            // content from CoachCubit
            Expanded(
              child: BlocBuilder<CoachCubit, CoachState>(
                builder: (context, state) {
                  if (state is CoachInitial || state is CoachLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CoachError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Couldn\'t load your coach right now.\n${state.message}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: BudgetaColors.textMuted),
                        ),
                      ),
                    );
                  }

                  final loaded = state as CoachLoaded;
                  final primaryAlert = loaded.alerts.isNotEmpty
                      ? loaded.alerts.first
                      : null;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (primaryAlert != null) ...[
                          _HomeAlertBanner(alert: primaryAlert),
                          const SizedBox(height: 18),
                        ],

                        // title + "See all" -> coach feed
                        MagicSectionTitle(
                          "Today's Magic 💖",
                          trailingIcon: Icons.chevron_right,
                          onTrailingTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CoachFeedScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Daily tip card (UC: Send Daily Tip)
                        if (loaded.todayTip != null) ...[
                          CoachTipCard(
                            icon: PhosphorIconsFill.sparkle,
                            iconBg: const Color(0xFFFFEBE6),
                            title: loaded.todayTip!.title,
                            label: loaded.todayTip!.label,
                            description: loaded.todayTip!.body,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CoachSettingsScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Weekly summary card (UC: Weekly Summary)
                        if (loaded.weeklySummary != null) ...[
                          CoachTipCard(
                            icon: FeatherIcons.award,
                            iconBg: const Color(0xFFFFF1DF),
                            title: loaded.weeklySummary!.title,
                            label: loaded.weeklySummary!.label,
                            description: loaded.weeklySummary!.body,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Behaviour nudges (UC: adaptive advice / anomalies)
                        if (loaded.nudges.isNotEmpty) ...[
                          const MagicSectionTitle('Smart nudges for you'),
                          const SizedBox(height: 12),
                          for (final nudge in loaded.nudges) ...[
                            CoachTipCard(
                              icon: FeatherIcons.zap,
                              iconBg: const Color(0xFFE3F2FD),
                              title: nudge.title,
                              label: nudge.label,
                              description: nudge.body,
                            ),
                            const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 8),
                        ],

                        // Encouragement card (gamified / motivation)
                        const CoachHighlightCard(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // 👉 app-wide bottom nav (Coach tab = index 3)
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 3),
    );
  }
}

/// Small alert banner on the home screen showing the most urgent alert.
class _HomeAlertBanner extends StatelessWidget {
  final Alert alert;
  const _HomeAlertBanner({required this.alert});

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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _bgForType(alert.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForType(alert.type),
              size: 18,
              color: BudgetaColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              alert.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BudgetaColors.deep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<CoachCubit>().dismissAlert(alert.id);
            },
            child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// One tip card (icon on the left, title + label + description)
class CoachTipCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String label;
  final String description;
  final VoidCallback? onTap;

  const CoachTipCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.label,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: MagicCard(
        borderRadius: 18,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // circular icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: BudgetaColors.primary),
            ),
            const SizedBox(width: 12),

            // title + label + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title + tiny dot
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: BudgetaColors.deep,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFB47CFF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BudgetaColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
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
      ),
    );
  }
}

/// Large “You’re doing amazing!” card at the bottom
class CoachHighlightCard extends StatelessWidget {
  const CoachHighlightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BudgetaColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // top round arrow icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: BudgetaColors.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              FeatherIcons.trendingUp,
              size: 20,
              color: BudgetaColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "You're doing amazing! 🌟",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: BudgetaColors.deep,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Keep tracking your expenses and watch your savings grow. Every small step counts towards your dreams!",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BudgetaColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
