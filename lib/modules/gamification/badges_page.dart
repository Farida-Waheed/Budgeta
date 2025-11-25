import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/colors.dart';
import 'gamification_controller.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GamificationController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Badges")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.badges.length,
        itemBuilder: (_, index) {
          final badge = controller.badges[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: badge.earned
                  ? AppColors.pink.withValues(alpha: 0.2)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  badge.earned
                      ? Icons.emoji_events
                      : Icons.lock_outline,
                  color: badge.earned ? AppColors.red : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    badge.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
