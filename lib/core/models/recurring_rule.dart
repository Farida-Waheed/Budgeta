// lib/core/models/recurring_rule.dart
import 'package:flutter/foundation.dart';

enum RecurringFrequency { daily, weekly, monthly, yearly }

@immutable
class RecurringRule {
  final String id;
  final String userId;
  final double amount;
  final DateTime startDate;
  final DateTime? endDate;
  final RecurringFrequency frequency;
  final String categoryId;

  /// Whether the rule is currently active.
  final bool isActive;

  /// Next due date for auto-posting.
  /// If null, the system should treat [startDate] as nextDueDate.
  final DateTime? nextDueDate;

  const RecurringRule({
    required this.id,
    required this.userId,
    required this.amount,
    required this.startDate,
    required this.frequency,
    required this.categoryId,
    this.endDate,
    this.isActive = true,
    this.nextDueDate,
  });

  RecurringRule copyWith({
    String? id,
    String? userId,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    RecurringFrequency? frequency,
    String? categoryId,
    bool? isActive,
    DateTime? nextDueDate,
  }) {
    return RecurringRule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      frequency: frequency ?? this.frequency,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }
}
