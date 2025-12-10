// lib/core/models/category_rule.dart
import 'package:flutter/foundation.dart';

@immutable
class CategoryRule {
  final String id;
  final String userId;

  /// Simple substring pattern to match in the transaction note.
  /// Example: "rent", "starbucks", "uber"
  final String pattern;

  /// Target category id, e.g. "rent", "coffee", "salary".
  final String categoryId;

  final bool isActive;

  const CategoryRule({
    required this.id,
    required this.userId,
    required this.pattern,
    required this.categoryId,
    this.isActive = true,
  });

  CategoryRule copyWith({
    String? id,
    String? userId,
    String? pattern,
    String? categoryId,
    bool? isActive,
  }) {
    return CategoryRule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pattern: pattern ?? this.pattern,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
    );
  }
}
