// lib/features/coach/presentation/screens/coach_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme.dart';

import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../shared/bottom_nav.dart';
import '../../../../core/models/alert.dart';

import '../../state/coach_cubit.dart';

import 'alerts_screen.dart';
import 'coach_feed_screen.dart';
import 'coach_settings_screen.dart';

class CoachHomeScreen extends StatelessWidget {
  const CoachHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CoachCubit is provided globally in main.dart
    return const _CoachHomeView();
  }
}

class _CoachHomeView extends StatelessWidget {
  const _CoachHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 3),

      body: Column(
        children: [
          _CoachHeader(
            title: 'Your AI Coach 💖',
            subtitle: 'Daily magic crafted for you!',
            onNotifications: () {
              final cubit = context.read<CoachCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const AlertsScreen(),
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: SafeArea(
              top: false, // let the gradient stay behind the status bar
              child: BlocBuilder<CoachCubit, CoachState>(
                builder: (context, state) {
                  if (state is CoachLoading || state is CoachInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CoachError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Couldn’t load your coach.\n${state.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final loaded = state as CoachLoaded;
                  final primaryAlert = loaded.alerts.isNotEmpty
                      ? loaded.alerts.first
                      : null;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (primaryAlert != null) ...[
                          _AlertBanner(alert: primaryAlert),
                          const SizedBox(height: 18),
                        ],

                        // "Today's Magic"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Today's Magic ✨",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: BudgetaColors.deep,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CoachFeedScreen(),
                                  ),
                                );
                              },
                              child: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        if (loaded.todayTip != null)
                          _CoachTipCard(
                            icon: PhosphorIconsFill.sparkle,
                            bg: const Color(0xFFFFEBE6),
                            title: loaded.todayTip!.title,
                            label: loaded.todayTip!.label,
                            desc: loaded.todayTip!.body,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CoachSettingsScreen(),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 16),

                        if (loaded.weeklySummary != null)
                          _CoachTipCard(
                            icon: FeatherIcons.award,
                            bg: const Color(0xFFFFF1DF),
                            title: loaded.weeklySummary!.title,
                            label: loaded.weeklySummary!.label,
                            desc: loaded.weeklySummary!.body,
                          ),

                        const SizedBox(height: 24),

                        if (loaded.nudges.isNotEmpty) ...[
                          const Text(
                            'Smart nudges for you 💡',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: BudgetaColors.deep,
                            ),
                          ),
                          const SizedBox(height: 12),

                          for (final n in loaded.nudges)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CoachTipCard(
                                icon: FeatherIcons.zap,
                                bg: const Color(0xFFE3F2FD),
                                title: n.title,
                                label: n.label,
                                desc: n.body,
                              ),
                            ),
                        ],

                        const SizedBox(height: 20),

                        const _CoachHighlightCard(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// HEADER
//
class _CoachHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onNotifications;

  const _CoachHeader({
    required this.title,
    required this.subtitle,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        44,
        20,
        26,
      ), // ⬅️ top: 44 like other big headers
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [BudgetaColors.primary, BudgetaColors.deep],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: onNotifications,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 18),

          // Mini welcome glass card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Your personalized guidance awaits ✨",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.3,
                    ),
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

//
// ALERT BANNER
//
class _AlertBanner extends StatelessWidget {
  final Alert alert;

  const _AlertBanner({required this.alert});

  IconData _getIcon(AlertType t) {
    switch (t) {
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

  Color _getBg(AlertType t) {
    switch (t) {
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getBg(alert.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(alert.type),
              size: 18,
              color: BudgetaColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: BudgetaColors.deep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// TIP CARD
//
class _CoachTipCard extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final String title;
  final String label;
  final String desc;
  final VoidCallback? onTap;

  const _CoachTipCard({
    super.key,
    required this.icon,
    required this.bg,
    required this.title,
    required this.label,
    required this.desc,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, color: BudgetaColors.primary, size: 20),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: BudgetaColors.deep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: BudgetaColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
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
      ),
    );
  }
}

//
// Highlight Card
//
class _CoachHighlightCard extends StatelessWidget {
  const _CoachHighlightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      margin: const EdgeInsets.only(bottom: 24),
      constraints: const BoxConstraints(minHeight: 170),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: BudgetaColors.primary.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: BudgetaColors.primary.withOpacity(0.5)),
            ),
            child: const Icon(
              FeatherIcons.trendingUp,
              size: 24,
              color: BudgetaColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "You're doing amazing! 🌟",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BudgetaColors.deep,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Every small step moves you closer to your goals!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: BudgetaColors.textMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
