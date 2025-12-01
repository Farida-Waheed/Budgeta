import 'package:flutter/material.dart';
import '../../../../../app/theme.dart';
import '../../../../../shared/bottom_nav.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetaColors.background,
      appBar: AppBar(
        backgroundColor: BudgetaColors.background,
        foregroundColor: BudgetaColors.deep,
        title: const Text('Community'),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: const BudgetaBottomNav(currentIndex: 5),
      body: const Center(
        child: Text(
          'Community & Social Sharing\n(dummy screen for now)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
