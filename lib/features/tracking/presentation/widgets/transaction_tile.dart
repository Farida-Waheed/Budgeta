// lib/features/tracking/presentation/widgets/transaction_tile.dart
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final sign = isExpense ? '-' : '+';

    final amountColor = isExpense
        ? BudgetaColors.primary
        : Colors.green.shade700;

    final title = transaction.note ?? 'No note';
    final subtitle = _capitalize(transaction.categoryId);
    final dateString = transaction.date.toLocal().toString().split(' ').first;

    // Simple MVP logic: if note contains "Receipt attached",
    // show a small paperclip icon.
    final hasReceipt = (transaction.note ?? '').toLowerCase().contains(
      'receipt attached',
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: BudgetaColors.accentLight.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // circular icon like the mockup
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isExpense
                      ? BudgetaColors.accentLight.withValues(alpha: 0.5)
                      : Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpense
                      ? Icons.trending_down_rounded
                      : Icons.trending_up_rounded,
                  color: amountColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (hasReceipt) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.attachment_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateString,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Text(
                '$sign${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(width: 4),

              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                color: Colors.black45,
                onPressed: onDelete == null
                    ? null
                    : () {
                        onDelete!.call();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
