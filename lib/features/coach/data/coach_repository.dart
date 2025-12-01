// lib/features/coach/data/coach_repository.dart
import '../../../core/models/coaching_tip.dart';
import '../../../core/models/alert.dart';
import '../../../core/models/insight.dart';

abstract class CoachRepository {
  // UC: View coach feed (tips + insights)
  Future<List<CoachingTip>> getCoachFeed(String userId);

  // UC: View alerts
  Future<List<Alert>> getAlerts(String userId);

  // UC: Dismiss / save tip
  Future<void> dismissTip(String tipId);
  Future<void> saveTip(String tipId);

  // UC: Mark alert as read
  Future<void> markAlertRead(String alertId);

  // UC: Ask a question to AI coach (chat)
  Future<CoachingTip> askCoach({
    required String userId,
    required String question,
  });

  // UC: AI insights reuse
  Future<List<Insight>> getInsights(String userId);
}
