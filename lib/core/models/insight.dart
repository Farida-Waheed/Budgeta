// lib/core/models/insight.dart
enum InsightType { overspending, trend, tip, alert }

class Insight {
  final String id;
  final String userId;
  final InsightType type;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;

  Insight({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
  });
}
