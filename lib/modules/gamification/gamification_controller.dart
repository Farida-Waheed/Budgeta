import 'package:flutter/material.dart';
import '../../data/models/app_badge.dart';
import '../../data/models/challenge.dart';

class GamificationController extends ChangeNotifier {
  List<AppBadge> badges = [
    AppBadge(
      id: "1",
      title: "Starter",
      description: "Created your first goal.",
    ),
    AppBadge(
      id: "2",
      title: "Tracker",
      description: "Logged 5 expenses.",
    ),
    AppBadge(
      id: "3",
      title: "Saver",
      description: "Saved 100 EGP.",
    ),
  ];

  List<Challenge> challenges = [
    Challenge(
      id: "1",
      title: "Log 3 expenses",
      description: "Track 3 expenses this week.",
      target: 3,
    ),
    Challenge(
      id: "2",
      title: "Save 50 EGP",
      description: "Add 50 EGP to any savings goal.",
      target: 50,
    ),
  ];

  void earnBadge(String badgeId) {
    badges = badges.map((b) {
      if (b.id == badgeId) {
        return b.earn();
      }
      return b;
    }).toList();

    notifyListeners();
  }

  void updateChallenge(String challengeId, int amount) {
    challenges = challenges.map((c) {
      if (c.id == challengeId) {
        return c.updateProgress(amount);
      }
      return c;
    }).toList();

    notifyListeners();
  }
}
