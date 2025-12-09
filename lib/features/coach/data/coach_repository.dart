// lib/features/coach/data/coach_repository.dart
import '../../../core/models/coaching_tip.dart';
import '../../../core/models/alert.dart';

abstract class CoachRepository {
  // UC: Send Daily Tip / Receive today's tip
  Future<CoachMessage?> getTodayTip(String userId);

  // UC: Send Weekly Summary
  Future<CoachMessage?> getWeeklySummary(String userId);

  // UC: Send Overspent Alert (read active alerts)
  Future<List<Alert>> getActiveAlerts(String userId);

  // UC: Suggest Budget Adjustment + Behavior Advice
  Future<List<CoachMessage>> getBehaviorNudges(String userId);

  // Mark alert as read / handled
  Future<void> markAlertAsRead(String alertId);
}
