// lib/features/coach/data/fake_coach_repository.dart
import 'dart:async';

import '../../../core/models/coaching_tip.dart';
import '../../../core/models/alert.dart';
import 'coach_repository.dart';

/// Simple in-memory implementation of CoachRepository.
/// This simulates the AI Coach use cases:
/// - daily tip
/// - weekly summary
/// - overspend / bill / goal alerts
/// - behavior nudges
class FakeCoachRepository implements CoachRepository {
  Future<T> _delay<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return value;
  }

  @override
  Future<CoachMessage?> getTodayTip(String userId) {
    return _delay(
      CoachMessage(
        id: 'tip-${DateTime.now().toIso8601String()}',
        userId: userId,
        type: CoachMessageType.dailyTip,
        title: 'Tiny tweak, big glow ✨',
        label: 'Daily Tip',
        body:
            'Save just 150 EGP more this week and you\'ll reach your closest goal about a month earlier.',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<CoachMessage?> getWeeklySummary(String userId) {
    return _delay(
      CoachMessage(
        id: 'weekly-${DateTime.now().toIso8601String()}',
        userId: userId,
        type: CoachMessageType.weeklySummary,
        title: 'This week\'s money story 📖',
        label: 'Weekly summary',
        body:
            'You tracked expenses on 4 of 7 days and stayed under budget in 3 categories. Dining out was the main risk area.',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<Alert>> getActiveAlerts(String userId) {
    final now = DateTime.now();
    final alerts = <Alert>[
      Alert(
        id: 'a1',
        userId: userId,
        type: AlertType.overspent,
        title: 'You overspent on Dining Out 🍕',
        message:
            'You are 30% above your usual dining budget this week. Try one no-delivery day to rebalance.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Alert(
        id: 'a2',
        userId: userId,
        type: AlertType.upcomingBill,
        title: 'Internet bill due in 3 days 📅',
        message: 'Your 450 EGP internet bill is coming up on Monday.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Alert(
        id: 'a3',
        userId: userId,
        type: AlertType.goalOffTrack,
        title: 'Dream Vacation is slightly off-track 🏖️',
        message:
            'You skipped saving last week. Add 200 EGP extra this week to stay on schedule.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
    return _delay(alerts);
  }

  @override
  Future<List<CoachMessage>> getBehaviorNudges(String userId) {
    final now = DateTime.now();
    final nudges = <CoachMessage>[
      CoachMessage(
        id: 'n1',
        userId: userId,
        type: CoachMessageType.behaviorNudge,
        title: 'Grocery list hack 🧺',
        label: 'Nudge',
        body:
            'Re-use last week\'s grocery list and remove only what you didn\'t use. That alone can cut 5–10% of waste.',
        createdAt: now,
      ),
      CoachMessage(
        id: 'n2',
        userId: userId,
        type: CoachMessageType.behaviorNudge,
        title: 'Cash envelope idea 💌',
        label: 'Nudge',
        body:
            'Put your weekly “fun money” in a separate wallet. When it\'s empty, fun pauses — not your whole budget.',
        createdAt: now,
      ),
    ];
    return _delay(nudges);
  }

  @override
  Future<void> markAlertAsRead(String alertId) async {
    // Just simulate a network call.
    await Future.delayed(const Duration(milliseconds: 250));
  }
}
