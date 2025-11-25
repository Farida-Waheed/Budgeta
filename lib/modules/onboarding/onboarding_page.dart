import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme/colors.dart';
import '../../state/onboarding_state.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarding = Provider.of<OnboardingState>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            SizedBox(
              height: 120,
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/logo.png', // <- put your app icon here
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Welcome to Budgeta",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            const Text(
              "Track expenses, save smarter, and stay on top of your money.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            _bullet("Add your expenses and goals easily."),
            const SizedBox(height: 8),
            _bullet("See your spending by category."),
            const SizedBox(height: 8),
            _bullet("Get motivated with challenges and rewards."),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await onboarding.completeOnboarding();
                  // main.dart already shows LoginPage / HomeNav depending on auth
                },
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
