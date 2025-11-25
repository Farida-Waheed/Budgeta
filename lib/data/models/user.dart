class UserModel {
  final String id;
  final String name;
  final String email;
  final double monthlyIncome;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.monthlyIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "monthlyIncome": monthlyIncome,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      name: map["name"],
      email: map["email"],
      monthlyIncome: map["monthlyIncome"],
    );
  }
}
