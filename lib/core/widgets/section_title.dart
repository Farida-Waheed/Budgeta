import 'package:flutter/material.dart';
import '../../app/theme.dart';

class MagicSectionTitle extends StatelessWidget {
  final String text;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  const MagicSectionTitle(
    this.text, {
    super.key,
    this.trailingIcon,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BudgetaColors.deep,
                fontWeight: FontWeight.w700,
              ),
        ),
        const Spacer(),
        if (trailingIcon != null)
          IconButton(
            iconSize: 18,
            padding: EdgeInsets.zero,
            splashRadius: 18,
            onPressed: onTrailingTap,
            icon: Icon(
              trailingIcon,
              color: BudgetaColors.primary,
            ),
          ),
      ],
    );
  }
}
