// lib/features/coach/data/in_memory_coach_repository.dart
import 'dart:async';

import '../../../core/models/coaching_tip.dart';
import '../../../core/models/alert.dart';
import 'coach_repository.dart';

/// In-memory implementation of CoachRepository.
/// Used by main.dart + CoachCubit for the AI Coach subsystem.
class InMemoryCoachRepository implements CoachRepository {
  // Later you can replace Object with your real TrackingRepository type.
  final Object trackingRepository;

  InMemoryCoachRepository({required this.trackingRepository}) {
    _seedDemoData();
  }

  CoachMessage? _todayTip;
  CoachMessage? _weeklySummary;
  final List<Alert> _alerts = [];
  final List<CoachMessage> _nudges = [];

  Future<T> _delay<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return value;
  }

  void _seedDemoData() {
    final now = DateTime.now();

    _todayTip = CoachMessage(
      id: 'tip-${now.toIso8601String()}',
      userId: 'demo-user',
      type: CoachMessageType.dailyTip,
      title: 'Tiny tweak, big glow ✨',
      label: 'Daily Tip',
      body:
          'Save just 150 EGP more this week and you\'ll reach your closest goal about a month earlier.',
      createdAt: now,
    );

    _weeklySummary = CoachMessage(
      id: 'weekly-${now.toIso8601String()}',
      userId: 'demo-user',
      type: CoachMessageType.weeklySummary,
      title: 'This week\'s money story 📖',
      label: 'Weekly summary',
      body:
          'You tracked expenses on 4 of 7 days and stayed under budget in 3 categories. Dining out was the main risk area.',
      createdAt: now,
    );

    _alerts.addAll([
      Alert(
        id: 'a1',
        userId: 'demo-user',
        type: AlertType.overspent,
        title: 'You overspent on Dining Out 🍕',
        message:
            'You are 30% above your usual dining budget this week. Try one no-delivery day to rebalance.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      Alert(
        id: 'a2',
        userId: 'demo-user',
        type: AlertType.upcomingBill,
        title: 'Internet bill due in 3 days 📅',
        message: 'Your 450 EGP internet bill is coming up on Monday.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Alert(
        id: 'a3',
        userId: 'demo-user',
        type: AlertType.goalOffTrack,
        title: 'Dream Vacation is slightly off-track 🏖️',
        message:
            'You skipped saving last week. Add 200 EGP extra this week to stay on schedule.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);

    _nudges.addAll([
      CoachMessage(
        id: 'n1',
        userId: 'demo-user',
        type: CoachMessageType.behaviorNudge,
        title: 'Grocery list hack 🧺',
        label: 'Nudge',
        body:
            'Re-use last week\'s grocery list and remove only what you didn\'t use. That alone can cut 5–10% of waste.',
        createdAt: now,
      ),
      CoachMessage(
        id: 'n2',
        userId: 'demo-user',
        type: CoachMessageType.behaviorNudge,
        title: 'Cash envelope idea 💌',
        label: 'Nudge',
        body:
            'Put your weekly “fun money” in a separate wallet. When it\'s empty, fun pauses — not your whole budget.',
        createdAt: now,
      ),
    ]);
  }

  @override
  Future<CoachMessage?> getTodayTip(String userId) {
    return _delay(_todayTip);
  }

  @override
  Future<CoachMessage?> getWeeklySummary(String userId) {
    return _delay(_weeklySummary);
  }

  @override
  Future<List<Alert>> getActiveAlerts(String userId) {
    return _delay(List<Alert>.unmodifiable(_alerts));
  }

  @override
  Future<List<CoachMessage>> getBehaviorNudges(String userId) {
    return _delay(List<CoachMessage>.unmodifiable(_nudges));
  }

  @override
  Future<void> markAlertAsRead(String alertId) async {
    _alerts.removeWhere((a) => a.id == alertId);
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
