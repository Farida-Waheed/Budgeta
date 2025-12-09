// lib/core/models/coaching_tip.dart

/// -------------------------
/// 1) Generic coach message
/// -------------------------
/// Used for: daily tip, weekly summary, overspend alert,
/// budget suggestion, behaviour nudges… i.e. the cards
/// you show on the Coach home screen / alerts, etc.
enum CoachMessageType {
  dailyTip,
  weeklySummary,
  overspendAlert,
  budgetSuggestion,
  behaviorNudge,
}

class CoachMessage {
  final String id;
  final String userId;
  final CoachMessageType type;

  /// Short title shown in bold in the card.
  final String title;

  /// Small chip text like "Daily Tip", "Weekly Win", "Alert".
  final String label;

  /// Main body of the coach message.
  final String body;

  final DateTime createdAt;
  final bool isRead;

  const CoachMessage({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.label,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
}

/// -------------------------
/// 2) Saved tip model
/// -------------------------
/// Used only in the Coach Feed screen (saved/bookmarked tips).
class CoachingTip {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isSaved;
  final bool isDismissed;

  CoachingTip({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isSaved = false,
    this.isDismissed = false,
  });
}
