// lib/core/models/transaction.dart
import 'package:flutter/foundation.dart';

enum TransactionType { income, expense }

@immutable
class Transaction {
  final String id;
  final String userId;
  final double amount;
  final DateTime date;
  final String? note;
  final String categoryId;
  final TransactionType type;

  // Optional link to Recurring subsystem
  final String? recurringRuleId;

  // Optional link to Gamification subsystem
  final bool isPartOfChallenge;

  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
    this.note,
    this.recurringRuleId,
    this.isPartOfChallenge = false,
  });

  // Used when editing/update without mutating original
  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    DateTime? date,
    String? note,
    String? categoryId,
    TransactionType? type,
    String? recurringRuleId,
    bool? isPartOfChallenge,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      isPartOfChallenge: isPartOfChallenge ?? this.isPartOfChallenge,
    );
  }
}
