import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../app/theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: BudgetaColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 6 icon cards at top (static) ---
              SizedBox(
                height: 200,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: List.generate(6, (i) {
                    final bool isPrimary = i == 0;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isPrimary
                              ? BudgetaColors.primary
                              : BudgetaColors.accentLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_outlined,
                        color: BudgetaColors.primary,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Transform your',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'money journey',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'into pure magic ✨',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Budget with joy, save with sparkle, and watch your dreams come true! '
                'Empowerment starts here, superstar! 💗',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: BudgetaColors.textSecondary,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BudgetaColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.dashboard,
                    );
                  },
                  child: const Text('Start Your Journey ✨'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
