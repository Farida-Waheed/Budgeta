import 'package:flutter/material.dart';
import '../../app/theme.dart';

class MagicToggleTabs extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const MagicToggleTabs({
    super.key,
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: BudgetaColors.cardBorder.withOpacity(0.6),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: i == selectedIndex
                        ? BudgetaColors.primary.withOpacity(0.12)
                        : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: i == selectedIndex
                              ? BudgetaColors.deep
                              : BudgetaColors.textMuted,
                          fontWeight: i == selectedIndex
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
