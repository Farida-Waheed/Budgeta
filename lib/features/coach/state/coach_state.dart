// lib/features/coach/state/coach_state.dart
part of 'coach_cubit.dart';

abstract class CoachState {}

class CoachInitial extends CoachState {}

class CoachLoading extends CoachState {}

/// Loaded data for AI Coach home + nudges.
class CoachLoaded extends CoachState {
  final CoachMessage? todayTip; // Daily tip card
  final CoachMessage? weeklySummary; // Weekly win / summary card
  final List<Alert> alerts; // Overspend / bill / goal alerts
  final List<CoachMessage> nudges; // Behavior nudges, suggestions

  CoachLoaded({
    required this.todayTip,
    required this.weeklySummary,
    required this.alerts,
    required this.nudges,
  });

  CoachLoaded copyWith({
    CoachMessage? todayTip,
    CoachMessage? weeklySummary,
    List<Alert>? alerts,
    List<CoachMessage>? nudges,
  }) {
    return CoachLoaded(
      todayTip: todayTip ?? this.todayTip,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      alerts: alerts ?? this.alerts,
      nudges: nudges ?? this.nudges,
    );
  }
}

class CoachError extends CoachState {
  final String message;
  CoachError(this.message);
}
