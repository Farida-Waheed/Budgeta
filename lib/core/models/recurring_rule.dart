// lib/core/models/recurring_rule.dart
enum RecurringFrequency { daily, weekly, monthly, yearly }

class RecurringRule {
  final String id;
  final String userId;
  final double amount;
  final DateTime startDate;
  final DateTime? endDate;
  final RecurringFrequency frequency;
  final String categoryId;
  final bool isActive;

  RecurringRule({
    required this.id,
    required this.userId,
    required this.amount,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.categoryId,
    this.isActive = true,
  });
}
