// lib/features/gamification/state/gamification_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/models/badge.dart';
import '../../../core/models/challenge.dart';
import '../data/gamification_repository.dart';

part 'gamification_state.dart';

class GamificationCubit extends Cubit<GamificationState> {
  GamificationCubit(this._repository, {required this.userId})
    : super(const GamificationState.initial());

  final GamificationRepository _repository;
  final String userId;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final challenges = await _repository.getChallenges(userId);
      final badges = await _repository.getBadges(userId);
      final feedback = _buildWeeklyFeedback(challenges, badges);
      emit(
        state.copyWith(
          isLoading: false,
          challenges: challenges,
          badges: badges,
          weeklyFeedback: feedback,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    try {
      final updated = await _repository.joinChallenge(userId, challengeId);
      final newList = state.challenges.map((c) {
        return c.id == updated.id ? updated : c;
      }).toList();
      final feedback = _buildWeeklyFeedback(newList, state.badges);

      emit(state.copyWith(challenges: newList, weeklyFeedback: feedback));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> completeToday(String challengeId) async {
    try {
      final updated = await _repository.markChallengeDayCompleted(
        userId: userId,
        challengeId: challengeId,
      );

      final newChallenges = state.challenges.map((c) {
        return c.id == updated.id ? updated : c;
      }).toList();
      final newBadges = await _repository.getBadges(userId);
      final feedback = _buildWeeklyFeedback(newChallenges, newBadges);

      emit(
        state.copyWith(
          challenges: newChallenges,
          badges: newBadges,
          weeklyFeedback: feedback,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  String _buildWeeklyFeedback(List<Challenge> challenges, List<Badge> badges) {
    final joined = challenges.where((c) => c.isJoined).toList();
    if (joined.isEmpty) {
      return 'Let’s start your first challenge this week! Pick one that matches your savings mood 💗';
    }

    final avgProgress =
        joined.map((c) => c.progress).fold<double>(0, (sum, p) => sum + p) /
        joined.length;

    if (avgProgress >= 0.75) {
      return 'You’re on fire this week! 🔥 Keep it up, you’re so close to smashing your goals.';
    } else if (avgProgress >= 0.4) {
      return 'Nice steady progress ✨ A few more “good money days” and you’ll be unstoppable.';
    } else {
      return 'Every small step counts 💕 Try to log one tiny win today – skip a coffee or move 50 EGP to savings.';
    }
  }
}
