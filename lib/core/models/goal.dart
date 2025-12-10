// lib/core/models/goal.dart
class GoalProjection {
  final DateTime? estimatedCompletionDate;
  final double suggestedMonthlySaving; // AI suggestion

  GoalProjection({
    required this.estimatedCompletionDate,
    required this.suggestedMonthlySaving,
  });

  GoalProjection copyWith({
    DateTime? estimatedCompletionDate,
    double? suggestedMonthlySaving,
  }) {
    return GoalProjection(
      estimatedCompletionDate:
          estimatedCompletionDate ?? this.estimatedCompletionDate,
      suggestedMonthlySaving:
          suggestedMonthlySaving ?? this.suggestedMonthlySaving,
    );
  }
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

  Goal copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    GoalProjection? projection,
    bool? isPrimary,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      projection: projection ?? this.projection,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
