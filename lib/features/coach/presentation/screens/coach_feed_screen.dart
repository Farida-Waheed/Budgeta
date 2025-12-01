// lib/features/coach/presentation/screens/coach_feed_screen.dart
import 'package:flutter/material.dart';

class CoachFeedScreen extends StatelessWidget {
  const CoachFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
      ),
      body: const Center(
        child: Text('Coach feed coming soon...'),
      ),
    );
  }
}
