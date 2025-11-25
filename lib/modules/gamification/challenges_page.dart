import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/colors.dart';
import 'gamification_controller.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GamificationController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Challenges")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.challenges.length,
        itemBuilder: (_, index) {
          final challenge = controller.challenges[index];

          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.rose.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: challenge.percentage.clamp(0.0, 1.0),
                  color: AppColors.red,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  "${challenge.progress} / ${challenge.target}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
