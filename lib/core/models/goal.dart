// lib/core/models/goal.dart
class GoalProjection {
  final DateTime? estimatedCompletionDate;
  final double suggestedMonthlySaving; // AI suggestion

  GoalProjection({
    required this.estimatedCompletionDate,
    required this.suggestedMonthlySaving,
  });
}

class Goal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime? targetDate;
  final GoalProjection? projection; // from AI use case
  final bool isPrimary; // "primary saving plan"

  Goal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
    this.targetDate,
    this.projection,
    this.isPrimary = false,
  });

  double get progress => (currentAmount / targetAmount).clamp(0, 1);
}
