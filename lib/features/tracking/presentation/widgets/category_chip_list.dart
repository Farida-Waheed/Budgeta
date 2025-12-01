import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class CategoryChipList extends StatefulWidget {
  /// Currently selected category id.
  /// Can be null when used as a filter (meaning "All categories").
  final String? selectedCategoryId;

  /// Called when user selects a category or "All".
  final ValueChanged<String?> onCategorySelected;

  /// If true → only show income categories (Salary + custom).
  /// If false → show expense categories + income categories + custom.
  final bool incomeOnly;

  /// If true → show an "All categories" chip (mainly for filters).
  final bool showAllChip;

  /// If true and [incomeOnly] is false → hide income categories
  /// (used for Add Expense screen so "Salary" doesn’t appear).
  final bool hideIncomeInExpense;

  const CategoryChipList({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.incomeOnly = false,
    this.showAllChip = false,
    this.hideIncomeInExpense = false,
  });

  @override
  State<CategoryChipList> createState() => _CategoryChipListState();
}

class _CategoryChipListState extends State<CategoryChipList> {
  // Base expense categories
  final List<_Category> _expenseCategories = const [
    _Category(id: 'food', name: 'Food'),
    _Category(id: 'coffee', name: 'Coffee'),
    _Category(id: 'rent', name: 'Rent'),
    _Category(id: 'transport', name: 'Transport'),
    _Category(id: 'subscription', name: 'Subscription'),
  ];

  // Base income categories
  final List<_Category> _incomeCategories = const [
    _Category(id: 'salary', name: 'Salary'),
  ];

  // User-added categories (both for income / expense screens)
  final List<_Category> _customCategories = [];

  List<_Category> get _currentCategories {
    if (widget.incomeOnly) {
      // Income mode: salary + any custom categories
      return [
        ..._incomeCategories,
        ..._customCategories,
      ];
    } else {
      // Default: expense + income + custom
      var list = <_Category>[
        ..._expenseCategories,
        ..._incomeCategories,
        ..._customCategories,
      ];

      // For Add Expense screen: hide income categories such as Salary
      if (widget.hideIncomeInExpense) {
        list = list.where((c) => c.id != 'salary').toList();
      }

      return list;
    }
  }

  Future<void> _addCategoryDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) {
                Navigator.pop(ctx);
              } else {
                Navigator.pop(ctx, text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final id =
          result.toLowerCase().replaceAll(RegExp(r'\s+'), '_'); // simple id
      setState(() {
        _customCategories.add(_Category(id: id, name: result));
      });
      widget.onCategorySelected(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _currentCategories;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (widget.showAllChip)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: const Text('All categories'),
                selected: widget.selectedCategoryId == null,
                selectedColor: BudgetaColors.accentLight,
                backgroundColor: BudgetaColors.background,
                labelStyle: TextStyle(
                  color: widget.selectedCategoryId == null
                      ? BudgetaColors.deep
                      : BudgetaColors.deep.withOpacity(0.7),
                  fontWeight: widget.selectedCategoryId == null
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
                side: BorderSide(
                  color: widget.selectedCategoryId == null
                      ? BudgetaColors.primary
                      : BudgetaColors.accentLight,
                ),
                onSelected: (_) => widget.onCategorySelected(null),
              ),
            ),
          ...categories.map((c) {
            final selected = widget.selectedCategoryId == c.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c.name),
                selected: selected,
                selectedColor: BudgetaColors.primary,
                backgroundColor: BudgetaColors.background,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : BudgetaColors.deep,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: selected
                      ? BudgetaColors.primary
                      : BudgetaColors.accentLight,
                ),
                onSelected: (_) => widget.onCategorySelected(c.id),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: const Icon(Icons.add, size: 16, color: BudgetaColors.deep),
              label: const Text(
                'Add category',
                style: TextStyle(color: BudgetaColors.deep),
              ),
              backgroundColor:
                  BudgetaColors.accentLight.withValues(alpha: 0.5),
              onPressed: _addCategoryDialog,
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  final String id;
  final String name;
  const _Category({required this.id, required this.name});
}
