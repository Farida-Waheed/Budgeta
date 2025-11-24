class TransactionModel {
  final String id;
  final String title;
  final double amount;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'],
        title: json['title'],
        amount: json['amount'],
      );
}
