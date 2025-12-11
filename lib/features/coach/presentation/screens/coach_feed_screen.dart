// lib/features/coach/presentation/screens/coach_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/models/coaching_tip.dart';
import '../../../../shared/bottom_nav.dart';

class CoachFeedScreen extends StatelessWidget {
  const CoachFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<CoachingTip> tips = [
      CoachingTip(
        id: 't1',
        userId: 'demo',
        title: 'Tiny tweak, big glow ✨',
        body:
            'If you save just 150 EGP more per week, you can reach your Dream Vacation 1 month earlier.',
        createdAt: DateTime.now(),
        isSaved: true,
      ),
      CoachingTip(
        id: 't2',
        userId: 'demo',
        title: 'Win: Groceries on point 🛒',
        body:
            'You kept groceries 10% below your usual average this month. Keep that list handy!',
        createdAt: DateTime.now(),
        isSaved: true,
      ),
      CoachingTip(
        id: 't3',
        userId: 'demo',
        title: 'Cash envelope hack 💌',
        body:
            'Try a small “fun” envelope each week. When it’s empty, fun is paused—not your whole budget.',
        createdAt: DateTime.now(),
        isSaved: true,
      ),
    ];

    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: Column(
        children: [
          // 🌈 BIG GRADIENT HEADER (with back arrow, matching CoachHome theme)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 12,
              right: 20,
              top: 44, // gradient covers status bar
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [BudgetaColors.primary, BudgetaColors.deep],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coach Feed 💬',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20, // match CoachHome
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your saved tips & insights.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12, // match CoachHome subtitle
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== BODY =====
          Expanded(
            child: SafeArea(
              top: false, // Keep gradient at top
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MagicSectionTitle('Saved tips'),
                    const SizedBox(height: 16),
                    for (final tip in tips) _TipTile(tip: tip),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 3),
    );
  }
}

class _TipTile extends StatelessWidget {
  final CoachingTip tip;

  const _TipTile({required this.tip});

  @override
  Widget build(BuildContext context) {
    return MagicCard(
      borderRadius: 18,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            FeatherIcons.messageCircle,
            size: 20,
            color: BudgetaColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BudgetaColors.deep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip.body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BudgetaColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            tip.isSaved ? FeatherIcons.bookmark : FeatherIcons.bookmark,
            size: 18,
            color: BudgetaColors.primary,
          ),
        ],
      ),
    );
  }
}
