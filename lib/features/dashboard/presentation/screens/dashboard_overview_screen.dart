// lib/features/dashboard/presentation/screens/dashboard_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme.dart';
import '../../../../app/router.dart';
import '../../../../core/widgets/primary_button.dart';

class DashboardOverviewScreen extends StatelessWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: BudgetaGradients.heroBackground,
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soft top-right heart
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    PhosphorIconsFill.heart,
                    color: BudgetaColors.primary
                        .withValues(alpha: 0.25), // was withOpacity
                    size: 18,
                  ),
                ),
                const SizedBox(height: 4),

                // 3x2 feature grid
                const _FeatureGrid(),
                const SizedBox(height: 28),

                // Text section
                Text(
                  'Transform your',
                  style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: BudgetaColors.textDark,
                          ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'money journey ',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          color: BudgetaColors.deep,
                          fontWeight: FontWeight.w700,
                        ),
                    children: const [
                      TextSpan(text: 'into pure magic ✨'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 2,
                      color: BudgetaColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      PhosphorIconsFill.heart,
                      size: 18,
                      color: BudgetaColors.primary,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Budget with joy, save with sparkle,\n'
                  'and watch your dreams come true!\n'
                  'Empowerment starts here, superstar! 💗',
                  style:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: BudgetaColors.textMuted,
                            height: 1.4,
                          ),
                ),

                const Spacer(),

                // Button with shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color:
                            BudgetaColors.deep.withValues(alpha: 0.25),
                        blurRadius: 24,
                        spreadRadius: -2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: PrimaryButton(
                    label: 'Start Your Journey ✨',
                    onPressed: () {
                      // Go to main dashboard and remove hero from back stack
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.dashboard,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Smaller tile grid to match the UI reference
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Same horizontal padding as the screen
    const horizontalPadding = 24.0;
    const spacing = 12.0;

    // Width available for the 3 columns
    final availableWidth =
        size.width - (horizontalPadding * 2) - (spacing * 2);

    // Each tile is exactly 1/3 of the available width
    final tileSize = availableWidth / 3;

    // Height for 2 rows of squares + spacing between them
    final gridHeight = tileSize * 2 + spacing;

    return SizedBox(
      height: gridHeight,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1, // perfect squares
        // 🔥 NOT const anymore because icons/routes are not const
        children: [
          _FeatureCard(
            icon: LucideIcons.sparkles,
            routeName: AppRoutes.transactions, // tracking
            isPrimary: true,
          ),
          _FeatureCard(
            icon: PhosphorIconsLight.heart,
            routeName: AppRoutes.goals,
          ),
          _FeatureCard(
            icon: LucideIcons.trendingUp,
            routeName: AppRoutes.dashboard,
          ),
          _FeatureCard(
            icon: LucideIcons.target,
            routeName: AppRoutes.coach,
          ),
          _FeatureCard(
            icon: FeatherIcons.star,
            routeName: AppRoutes.challenges,
          ),
          _FeatureCard(
            icon: FeatherIcons.activity,
            routeName: AppRoutes.community,
          ),
        ],
      ),
    );
  }
}

/// Perfect floating boxes with matching shadow style
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String routeName;
  final bool isPrimary;

  const _FeatureCard({
    super.key,
    required this.icon,
    required this.routeName,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final border =
        isPrimary ? BudgetaColors.primary : BudgetaColors.cardBorder;
    final bg = isPrimary
        ? BudgetaColors.primary.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.65);
    final iconColor = isPrimary
        ? BudgetaColors.deep
        : BudgetaColors.primary.withValues(alpha: 0.85);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border, width: isPrimary ? 2 : 1.2),
          color: bg,
          boxShadow: [
            BoxShadow(
              color:
                  BudgetaColors.deep.withValues(alpha: 0.12),
              blurRadius: 20,
              spreadRadius: -1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
