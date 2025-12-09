// lib/features/coach/state/coach_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/coaching_tip.dart';
import '../../../core/models/alert.dart';
import '../data/coach_repository.dart';

part 'coach_state.dart';

class CoachCubit extends Cubit<CoachState> {
  final CoachRepository repository;
  final String userId;

  CoachCubit({required this.repository, required this.userId})
    : super(CoachInitial());

  /// Loads everything needed for the main Coach home screen:
  /// - today's tip
  /// - weekly summary
  /// - active alerts
  /// - behavior nudges
  Future<void> loadCoachHome() async {
    emit(CoachLoading());
    try {
      final todayTip = await repository.getTodayTip(userId);
      final weekly = await repository.getWeeklySummary(userId);
      final alerts = await repository.getActiveAlerts(userId);
      final nudges = await repository.getBehaviorNudges(userId);

      emit(
        CoachLoaded(
          todayTip: todayTip,
          weeklySummary: weekly,
          alerts: alerts,
          nudges: nudges,
        ),
      );
    } catch (e) {
      emit(CoachError(e.toString()));
    }
  }

  /// Optimistic “swipe away” dismiss of an alert.
  Future<void> dismissAlert(String alertId) async {
    if (state is! CoachLoaded) return;
    final current = state as CoachLoaded;

    final updatedAlerts = current.alerts
        .where((a) => a.id != alertId)
        .toList(growable: false);

    emit(current.copyWith(alerts: updatedAlerts));

    try {
      await repository.markAlertAsRead(alertId);
    } catch (_) {
      // could revert or show snack bar in real app
    }
  }
}
