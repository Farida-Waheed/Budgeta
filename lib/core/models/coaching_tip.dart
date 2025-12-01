// lib/core/models/coaching_tip.dart
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
