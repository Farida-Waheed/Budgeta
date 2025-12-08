// lib/core/widgets/bottom_nav.dart
import 'package:flutter/material.dart';
import '../../app/theme.dart';

class MagicBottomNavItem {
  final IconData icon;
  final String label;

  const MagicBottomNavItem({required this.icon, required this.label});
}

/// 👉 Shared main nav items used across all screens
const List<MagicBottomNavItem> kMainNavItems = [
  MagicBottomNavItem(icon: Icons.home_filled, label: 'Home'),
  MagicBottomNavItem(icon: Icons.receipt_long, label: 'Tracking'),
  MagicBottomNavItem(icon: Icons.flag_rounded, label: 'Goals'),
  MagicBottomNavItem(icon: Icons.auto_awesome, label: 'Coach'),
  MagicBottomNavItem(icon: Icons.group, label: 'Community'),
];

class MagicBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<MagicBottomNavItem> items;
  final ValueChanged<int> onTap;

  const MagicBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isActive = index == currentIndex;

          final iconColor = isActive
              ? BudgetaColors.primary
              : BudgetaColors.textMuted.withValues(alpha: 0.9);
          final labelColor = isActive
              ? BudgetaColors.deep
              : BudgetaColors.textMuted.withValues(alpha: 0.9);

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 22, color: iconColor),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 10,
                    child: isActive
                        ? CustomPaint(
                            size: const Size(14, 6),
                            painter: _DownTrianglePainter(
                              color: BudgetaColors.primary.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DownTrianglePainter extends CustomPainter {
  final Color color;
  _DownTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DownTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
