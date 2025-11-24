class GoalModel {
  final String id;
  final String name;
  final double target;

  GoalModel({
    required this.id,
    required this.name,
    required this.target,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'target': target,
      };
}
