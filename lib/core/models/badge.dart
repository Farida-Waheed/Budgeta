// lib/core/models/badge.dart
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final bool unlocked;
  final DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.unlocked = false,
    this.unlockedAt,
  });
}
