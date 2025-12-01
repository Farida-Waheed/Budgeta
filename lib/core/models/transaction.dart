// lib/core/models/transaction.dart
enum TransactionType { expense, income }

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String? note;
  final String categoryId;
  final TransactionType type;
  final String? recurringRuleId;
  final bool isPartOfChallenge; // links to gamification use case

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    this.note,
    required this.categoryId,
    required this.type,
    this.recurringRuleId,
    this.isPartOfChallenge = false,
  });
}
