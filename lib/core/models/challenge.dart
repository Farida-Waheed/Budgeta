// lib/core/models/challenge.dart
class Challenge {
  final String id;
  final String name;
  final String description;
  final int durationDays;
  final double? targetAmount; // for saving challenges
  final DateTime startDate;
  final DateTime? endDate;
  final bool isJoined;
  final int daysCompleted;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    this.targetAmount,
    required this.startDate,
    this.endDate,
    this.isJoined = false,
    this.daysCompleted = 0,
  });

  double get progress => (daysCompleted / durationDays).clamp(0, 1);
}
