// lib/core/models/badge.dart
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconName; // Can be emoji or icon key
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

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
