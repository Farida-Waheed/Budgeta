// lib/features/gamification/state/gamification_state.dart
part of 'gamification_cubit.dart';

class GamificationState extends Equatable {
  final bool isLoading;
  final List<Challenge> challenges;
  final List<Badge> badges;
  final String weeklyFeedback;
  final String? errorMessage;

  const GamificationState({
    required this.isLoading,
    required this.challenges,
    required this.badges,
    required this.weeklyFeedback,
    required this.errorMessage,
  });

  const GamificationState.initial()
    : isLoading = false,
      challenges = const [],
      badges = const [],
      weeklyFeedback = '',
      errorMessage = null;

  GamificationState copyWith({
    bool? isLoading,
    List<Challenge>? challenges,
    List<Badge>? badges,
    String? weeklyFeedback,
    String? errorMessage,
  }) {
    return GamificationState(
      isLoading: isLoading ?? this.isLoading,
      challenges: challenges ?? this.challenges,
      badges: badges ?? this.badges,
      weeklyFeedback: weeklyFeedback ?? this.weeklyFeedback,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    challenges,
    badges,
    weeklyFeedback,
    errorMessage,
  ];
}
