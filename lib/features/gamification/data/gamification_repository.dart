// lib/features/gamification/data/gamification_repository.dart
import '../../../core/models/challenge.dart';
import '../../../core/models/badge.dart';

abstract class GamificationRepository {
  // UC: List challenges
  Future<List<Challenge>> getChallenges(String userId);

  // UC: Join challenge
  Future<Challenge> joinChallenge(String userId, String challengeId);

  // UC: Update daily progress (e.g. "completed today's task")
  Future<Challenge> markChallengeDayCompleted({
    required String userId,
    required String challengeId,
  });

  // UC: View achievements / badges
  Future<List<Badge>> getBadges(String userId);
}
