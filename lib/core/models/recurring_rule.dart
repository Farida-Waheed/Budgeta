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
  final bool isActive;

  const RecurringRule({
    required this.id,
    required this.userId,
    required this.amount,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.categoryId,
    this.isActive = true,
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
    );
  }
}
