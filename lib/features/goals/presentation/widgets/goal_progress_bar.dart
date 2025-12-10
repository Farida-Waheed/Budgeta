import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

class GoalProgressBar extends StatelessWidget {
  final double progress;

  const GoalProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 8,
        decoration: const BoxDecoration(
          // light pink track (same feel as design)
          color: Color(0xFFFFF1F5),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: clamped,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: const BoxDecoration(
                  // gradient bar from deep to light pink
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB3125D), // deep
                      Color(0xFFFF8BA7), // light
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
