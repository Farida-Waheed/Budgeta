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

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    int? durationDays,
    double? targetAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isJoined,
    int? daysCompleted,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      durationDays: durationDays ?? this.durationDays,
      targetAmount: targetAmount ?? this.targetAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isJoined: isJoined ?? this.isJoined,
      daysCompleted: daysCompleted ?? this.daysCompleted,
    );
  }
}
