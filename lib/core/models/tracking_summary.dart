// lib/core/models/tracking_summary.dart
import 'package:flutter/foundation.dart';

@immutable
class TrackingSummary {
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> perCategoryTotals;
  final int transactionCount;

  const TrackingSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.perCategoryTotals,
    required this.transactionCount,
  });

  double get net => totalIncome - totalExpense;
}
