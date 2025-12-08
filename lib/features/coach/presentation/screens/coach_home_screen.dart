// lib/features/coach/presentation/screens/coach_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme.dart';

// shared widgets
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/bottom_nav.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  int _currentTab = 1; // assume Coach is the middle tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const MagicGradientHeader(
              title: 'Your AI Coach ✨',
              subtitle: 'Personalized tips just for you!',
              trailingIcon: Icons.auto_awesome, // sparkle-like icon
            ),

            // content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MagicSectionTitle("Today's Magic 💖"),
                    const SizedBox(height: 16),

                    // three tip cards
                    const CoachTipCard(
                      icon: FeatherIcons.coffee,
                      iconBg: Color(0xFFFFE5F0),
                      title: 'Coffee Spending Alert ☕',
                      label: 'Alert',
                      description:
                          "You’ve spent \$45 on coffee this week! Maybe brew at home and save for your dream vacation?",
                    ),
                    const SizedBox(height: 12),
                    const CoachTipCard(
                      icon: PhosphorIconsFill.sparkle,
                      iconBg: Color(0xFFFFEBE6),
                      title: 'Morning Motivation ✨',
                      label: 'Daily Tip',
                      description:
                          "Great job tracking your expenses! You’re building amazing financial habits. Keep sparkling!",
                    ),
                    const SizedBox(height: 12),
                    const CoachTipCard(
                      icon: FeatherIcons.award,
                      iconBg: Color(0xFFFFF1DF),
                      title: 'Weekly Win 🎉',
                      label: 'Insight',
                      description:
                          "You stayed under budget in 4 out of 5 categories! You’re crushing it, superstar!",
                    ),
                    const SizedBox(height: 24),

                    // big encouragement card (second mock)
                    const CoachHighlightCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // bottom tiny-triangle nav reused from MagicBottomNav
      bottomNavigationBar: MagicBottomNav(
        currentIndex: _currentTab,
        items: const [
          MagicBottomNavItem(
            icon: FeatherIcons.home,
            label: 'Overview',
          ),
          MagicBottomNavItem(
            icon: FeatherIcons.star, // Coach tab
            label: 'Coach',
          ),
          MagicBottomNavItem(
            icon: FeatherIcons.users,
            label: 'Community',
          ),
        ],
        onTap: (index) {
          // NOTE: for now we just switch highlight.
          // You can later plug real navigation here.
          setState(() => _currentTab = index);
        },
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

  const CoachTipCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return MagicCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // circular icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: BudgetaColors.primary,
            ),
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
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}

/// Large “You’re doing amazing!” card at the bottom of mock 2
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