import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart'; // ExpenseCategory, kCategories, getCategoryByName

// ── Expense model ─────────────────────────────────────────────────────────────

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;
  final String? note;
  final String paymentMethod;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.isIncome,
    this.note,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id:       json['id']       as String,
    title:    json['title']    as String,
    amount:   (json['amount']  as num).toDouble(),
    category: json['category'] as String,
    date:     DateTime.parse(json['date'] as String),
    isIncome: json['isIncome'] as bool,
    note:     json['note']     as String?, paymentMethod: '',
  );

  Map<String, dynamic> toJson() => {
    'id':       id,
    'title':    title,
    'amount':   amount,
    'category': category,
    'date':     date.toIso8601String(),
    'isIncome': isIncome,
    if (note != null) 'note': note,
  };
}

// ── Budget model ──────────────────────────────────────────────────────────────

class Budget {
  final String id;
  final String category;
  final double limit;

  const Budget({
    required this.id,
    required this.category,
    required this.limit,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id:       json['id']       as String,
    category: json['category'] as String,
    limit:    (json['limit']   as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id':       id,
    'category': category,
    'limit':    limit,
  };
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;

  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary)),
        if (actionText != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionText!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.primary)),
          ),
      ],
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat         = getCategoryByName(expense.category);
    final fmt         = NumberFormat('#,##0');
    final sign        = expense.isIncome ? '+' : '-';
    final amountColor = expense.isIncome ? AppTheme.income : AppTheme.expense;

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.expense),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: expense.isIncome
                    ? AppTheme.income.withValues(alpha: 0.1)
                    : cat.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(expense.isIncome ? '💰' : cat.emoji,
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                      expense.isIncome ? 'Income' : expense.category,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$sign₹${fmt.format(expense.amount)}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: amountColor)),
                const SizedBox(height: 2),
                Text(DateFormat('h:mm a').format(expense.date),
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}