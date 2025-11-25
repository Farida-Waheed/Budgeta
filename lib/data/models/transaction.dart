enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final TransactionType type;
  final String? receiptImage;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.note,
    this.receiptImage,
  });

  // For saving to local storage / API
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "amount": amount,
      "category": category,
      "date": date.toIso8601String(),
      "note": note,
      "type": type.name,
      "receiptImage": receiptImage,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map["id"],
      amount: map["amount"],
      category: map["category"],
      date: DateTime.parse(map["date"]),
      note: map["note"],
      type: map["type"] == "income"
          ? TransactionType.income
          : TransactionType.expense,
      receiptImage: map["receiptImage"],
    );
  }
}
