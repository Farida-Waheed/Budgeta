// lib/core/widgets/card.dart
import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Generic reusable card (you can keep using it in other screens)
class MagicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const MagicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 10),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: BudgetaColors.cardBorder.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// -----------------
/// BALANCE CARD (hero)
/// -----------------
class BalanceCard extends StatelessWidget {
  final String title;
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    required this.title,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Total Balance"
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BudgetaColors.textMuted.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
          ),
          const SizedBox(height: 8),

          // $2326.52
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 12),

          // $2500.00       $173.48
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '\$${income.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Icon(
                    Icons.trending_down,
                    size: 16,
                    color: Color(0xFFE57373),
                  ),
                  SizedBox(width: 4),
                  // we will pass the formatted value from parent
                ],
              ),
              // we keep spacing consistent by placing expense text in a Flexible
              Row(
                children: [
                  const SizedBox(width: 0), // just to match structure
                  Text(
                    '\$${expense.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE57373),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// -----------------
/// QUICK STAT CARD
/// -----------------
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: BudgetaColors.cardBorder.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // circle icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BudgetaColors.primary.withOpacity(0.08),
            ),
            child: Icon(
              icon,
              size: 20,
              color: BudgetaColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: BudgetaColors.deep,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BudgetaColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

/// -----------------
/// TOP SPENDING BAR
/// -----------------
class SpendingBarTile extends StatelessWidget {
  final String category;
  final double amount;
  final double ratio; // e.g. 0.52 = 52%

  const SpendingBarTile({
    super.key,
    required this.category,
    required this.amount,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (ratio * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: BudgetaColors.cardBorder.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row: name + amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BudgetaColors.deep,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BudgetaColors.deep,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(
                    color: const Color(0xFFFFEEF3),
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio.clamp(0.0, 1.0),
                    child: Container(
                      color: BudgetaColors.deep,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          Text(
            '$percentage% of total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BudgetaColors.textMuted.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }
}

/// -----------------
/// RECENT ACTIVITY TILE
/// -----------------
class ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount; // negative = expense, positive = income

  const ActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = amount > 0;
    final String displayAmount =
        '${isIncome ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}';
    final Color amountColor =
        isIncome ? const Color(0xFF2E7D32) : const Color(0xFFE53935);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: BudgetaColors.cardBorder.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BudgetaColors.primary.withOpacity(0.08),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: BudgetaColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BudgetaColors.deep,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BudgetaColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            displayAmount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
