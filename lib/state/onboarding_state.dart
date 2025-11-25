import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState extends ChangeNotifier {
  bool isDone = false;
  bool isLoading = true;

  OnboardingState() {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isDone = prefs.getBool("onboarding_done") ?? false;
    isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_done", true);
    isDone = true;
    notifyListeners();
  }
}
