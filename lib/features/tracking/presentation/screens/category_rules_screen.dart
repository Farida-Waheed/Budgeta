import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/category_rule.dart';
import '../../state/tracking_cubit.dart';
import '../widgets/category_chip_list.dart';

class CategoryRulesScreen extends StatelessWidget {
  const CategoryRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TrackingCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Auto-Rules (Admin)'),
        backgroundColor: BudgetaColors.deep,
      ),
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          if (state is TrackingLoading || state is TrackingInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TrackingError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is TrackingLoaded) {
            final rules = state.categoryRules;
            if (rules.isEmpty) {
              return const Center(
                child: Text(
                  'No rules yet. Use the + button to add patterns\n'
                  'like "rent", "coffee", "uber"...',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rules.length,
              itemBuilder: (ctx, i) {
                final r = rules[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text('"${r.pattern}" → ${r.categoryId}'),
                    subtitle: Text(
                      r.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: r.isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: r.isActive,
                          onChanged: (val) {
                            final updated = r.copyWith(isActive: val);
                            cubit.addOrUpdateCategoryRule(updated);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => cubit.deleteCategoryRule(r.id),
                        ),
                      ],
                    ),
                    onTap: () => _showEditDialog(context, cubit, r),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: BudgetaColors.primary,
        onPressed: () => _showEditDialog(context, cubit, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    TrackingCubit cubit,
    CategoryRule? existing,
  ) {
    final patternController = TextEditingController(
      text: existing?.pattern ?? '',
    );
    String categoryId = existing?.categoryId ?? 'food';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            existing == null ? 'Add Category Rule' : 'Edit Category Rule',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: patternController,
                decoration: const InputDecoration(
                  labelText: 'Keyword / pattern',
                  hintText: 'Example: rent, starbucks, uber...',
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Target category',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 4),
              // Reuse CategoryChipList as a quick selector
              CategoryChipList(
                selectedCategoryId: categoryId,
                onCategorySelected: (id) {
                  if (id == null) return;
                  categoryId = id;
                },
                showAllChip: false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final pattern = patternController.text.trim();
                if (pattern.isEmpty) {
                  Navigator.pop(ctx);
                  return;
                }
                final userId = cubit.userId;
                final rule = CategoryRule(
                  id:
                      existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: userId,
                  pattern: pattern,
                  categoryId: categoryId,
                  isActive: existing?.isActive ?? true,
                );
                cubit.addOrUpdateCategoryRule(rule);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
