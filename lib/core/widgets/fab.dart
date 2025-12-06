import 'package:flutter/material.dart';
import '../../app/theme.dart';

class MagicFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const MagicFab({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF6FA0),
              Color(0xFF9B0F3F),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: BudgetaColors.deep.withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
