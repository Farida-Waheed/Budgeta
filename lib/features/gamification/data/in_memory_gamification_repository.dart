// lib/features/gamification/data/in_memory_gamification_repository.dart
import 'dart:math';

import '../../../core/models/badge.dart';
import '../../../core/models/challenge.dart';
import 'gamification_repository.dart';

/// Simple in-memory implementation so the UI is DYNAMIC:
/// - You can join challenges
/// - Mark days as completed
/// - Unlock some badges gradually
class InMemoryGamificationRepository implements GamificationRepository {
  InMemoryGamificationRepository();

  final Map<String, List<Challenge>> _challengesByUser = {};
  final Map<String, List<Badge>> _badgesByUser = {};

  List<Challenge> _seedChallenges(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return [
      Challenge(
        id: 'no_spend_week',
        name: 'No-Spend Week',
        description: 'Avoid non-essential spending for 7 days straight.',
        durationDays: 7,
        startDate: today,
        targetAmount: null,
      ),
      Challenge(
        id: 'coffee_cut',
        name: 'Coffee Cutback',
        description: 'Skip takeout coffee and save 200 EGP this week.',
        durationDays: 7,
        startDate: today,
        targetAmount: 200,
      ),
      Challenge(
        id: 'mini_emergency',
        name: 'Mini Emergency Fund',
        description: 'Save 1,000 EGP in 30 days for peace of mind.',
        durationDays: 30,
        startDate: today,
        targetAmount: 1000,
      ),
    ];
  }

  List<Badge> _seedBadges() {
    return [
      Badge(
        id: 'first_challenge',
        name: 'First Spark',
        description: 'Join your first Budgeta challenge.',
        iconName: '✨',
      ),
      Badge(
        id: 'streak_7',
        name: 'Weekly Streak',
        description: 'Complete 7 challenge days in total.',
        iconName: '🔥',
      ),
      Badge(
        id: 'goal_lover',
        name: 'Goal Lover',
        description: 'Have 2 or more active challenges at once.',
        iconName: '🎯',
      ),
    ];
  }

  List<Challenge> _getOrInitChallenges(String userId) {
    return _challengesByUser.putIfAbsent(
      userId,
      () => _seedChallenges(DateTime.now()),
    );
  }

  List<Badge> _getOrInitBadges(String userId) {
    return _badgesByUser.putIfAbsent(userId, _seedBadges);
  }

  @override
  Future<List<Challenge>> getChallenges(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_getOrInitChallenges(userId));
  }

  @override
  Future<Challenge> joinChallenge(String userId, String challengeId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final list = _getOrInitChallenges(userId);
    final idx = list.indexWhere((c) => c.id == challengeId);
    if (idx == -1) throw Exception('Challenge not found');

    final current = list[idx];
    final updated = current.copyWith(
      isJoined: true,
      daysCompleted: max(current.daysCompleted, 0),
    );
    list[idx] = updated;

    // Potentially unlock the "First Spark" badge
    final badges = _getOrInitBadges(userId);
    final firstSparkIdx = badges.indexWhere((b) => b.id == 'first_challenge');
    if (firstSparkIdx != -1 && !badges[firstSparkIdx].unlocked) {
      badges[firstSparkIdx] = badges[firstSparkIdx].copyWith(
        unlocked: true,
        unlockedAt: DateTime.now(),
      );
    }

    return updated;
  }

  @override
  Future<Challenge> markChallengeDayCompleted({
    required String userId,
    required String challengeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = _getOrInitChallenges(userId);
    final idx = list.indexWhere((c) => c.id == challengeId);
    if (idx == -1) throw Exception('Challenge not found');

    final current = list[idx];
    if (!current.isJoined) {
      throw Exception('Challenge not joined yet');
    }

    final newDays = (current.daysCompleted + 1).clamp(0, current.durationDays);
    final updated = current.copyWith(
      daysCompleted: newDays,
      endDate: newDays >= current.durationDays
          ? DateTime.now()
          : current.endDate,
    );
    list[idx] = updated;

    // Update badges based on total days completed across all challenges
    final totalDays = list
        .where((c) => c.isJoined)
        .fold<int>(0, (sum, c) => sum + c.daysCompleted);

    final badges = _getOrInitBadges(userId);
    final streakIdx = badges.indexWhere((b) => b.id == 'streak_7');
    if (streakIdx != -1 && !badges[streakIdx].unlocked && totalDays >= 7) {
      badges[streakIdx] = badges[streakIdx].copyWith(
        unlocked: true,
        unlockedAt: DateTime.now(),
      );
    }

    // Goal Lover badge – 2+ active challenges
    final activeCount = list.where((c) => c.isJoined).length;
    final goalLoverIdx = badges.indexWhere((b) => b.id == 'goal_lover');
    if (goalLoverIdx != -1 &&
        !badges[goalLoverIdx].unlocked &&
        activeCount >= 2) {
      badges[goalLoverIdx] = badges[goalLoverIdx].copyWith(
        unlocked: true,
        unlockedAt: DateTime.now(),
      );
    }

    return updated;
  }

  @override
  Future<List<Badge>> getBadges(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_getOrInitBadges(userId));
  }
}
