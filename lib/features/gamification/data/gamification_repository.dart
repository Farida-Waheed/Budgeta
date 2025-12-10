// lib/features/gamification/data/gamification_repository.dart
import '../../../core/models/badge.dart';
import '../../../core/models/challenge.dart';

/// Contract for the Gamification data source.
abstract class GamificationRepository {
  // UC: List challenges
  Future<List<Challenge>> getChallenges(String userId);

  // UC: Join challenge
  Future<Challenge> joinChallenge(String userId, String challengeId);

  // UC: Update daily progress
  Future<Challenge> markChallengeDayCompleted({
    required String userId,
    required String challengeId,
  });

  // UC: View achievements / badges
  Future<List<Badge>> getBadges(String userId);
}
