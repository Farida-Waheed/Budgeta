class Goal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime? expectedCompletionDate;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
    this.expectedCompletionDate,
  });

  double get progress => currentAmount / targetAmount;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "targetAmount": targetAmount,
      "currentAmount": currentAmount,
      "createdAt": createdAt.toIso8601String(),
      "expectedCompletionDate": expectedCompletionDate?.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map["id"],
      title: map["title"],
      targetAmount: map["targetAmount"],
      currentAmount: map["currentAmount"],
      createdAt: DateTime.parse(map["createdAt"]),
      expectedCompletionDate: map["expectedCompletionDate"] != null
          ? DateTime.parse(map["expectedCompletionDate"])
          : null,
    );
  }
}
