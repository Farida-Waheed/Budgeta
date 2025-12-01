// lib/core/models/category.dart
class Category {
  final String id;
  final String name;
  final bool isEssential;
  final bool isIncome;
  final String? iconName; // for UI (emoji / asset)

  Category({
    required this.id,
    required this.name,
    required this.isEssential,
    required this.isIncome,
    this.iconName,
  });
}
