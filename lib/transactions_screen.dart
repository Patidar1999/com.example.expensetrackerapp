import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'expense.dart'; // ExpenseTile, Expense

class TransactionsScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Function(String) onDelete;
  const TransactionsScreen(
      {super.key, required this.expenses, required this.onDelete});
  @override
  State<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _search = '';
  String _filter = 'All';
  final _categories = [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Health',
    'Entertainment',
    'Education',
    'Income',
  ];

  List<Expense> get _filtered {
    return widget.expenses.where((e) {
      final matchSearch =
      e.title.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'All'
          ? true
          : _filter == 'Income'
          ? e.isIncome
          : e.category == _filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  Map<String, List<Expense>> get _grouped {
    final map = <String, List<Expense>>{};
    for (final e in _filtered) {
      final key = _dayLabel(e.date);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) return 'TODAY';
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) return 'YESTERDAY';
    return DateFormat('MMM d, yyyy').format(date).toUpperCase();
  }

  // ─── Show Detail Bottom Sheet ───────────────────────────────────────────────
  void _showTransactionDetail(Expense expense) {
    final isIncome = expense.isIncome;
    final color = isIncome ? AppTheme.income : AppTheme.expense;
    final amountStr =
        '${isIncome ? '+' : '-'} ₹${NumberFormat('#,##,###.##').format(expense.amount)}';

    // Find category emoji
    final catObj = kCategories.firstWhere(
          (c) => c.name == expense.category,
      orElse: () => kCategories.first,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgPage,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Emoji + Category circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  catObj.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Amount
            Text(
              amountStr,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),

            // Title
            Text(
              expense.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Date
            Text(
              DateFormat('EEEE, MMM d yyyy • hh:mm a').format(expense.date),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: AppTheme.borderColor),
            const SizedBox(height: 12),

            // Detail rows
            _DetailRow(
              icon: Icons.category_rounded,
              label: 'Category',
              value: expense.category,
            ),
            _DetailRow(
              icon: Icons.payment_rounded,
              label: 'Payment Method',
              value: expense.paymentMethod.isNotEmpty
                  ? expense.paymentMethod
                  : '—',
            ),
            _DetailRow(
              icon: isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              label: 'Type',
              value: isIncome ? 'Income' : 'Expense',
              valueColor: color,
            ),
            if ((expense.note ?? '').isNotEmpty)
              _DetailRow(
                icon: Icons.notes_rounded,
                label: 'Note',
                value: expense.note!,
              ),

            const SizedBox(height: 20),

            // Delete button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onDelete(expense.id);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.expense.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.expense.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete_outline_rounded,
                        color: AppTheme.expense, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Delete Transaction',
                      style: TextStyle(
                        color: AppTheme.expense,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final keys = grouped.keys.toList();

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Transactions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search transactions...',
                            hintStyle: TextStyle(
                                color: Colors.white54, fontSize: 13),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Container(
            color: AppTheme.bgPage,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final active = _filter == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? AppTheme.primary : AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: active
                                ? AppTheme.primary
                                : AppTheme.borderColor),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color:
                          active ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                child: Text('No transactions found',
                    style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: keys.fold(
                  0, (s, k) => s! + 1 + (grouped[k]?.length ?? 0)),
              itemBuilder: (ctx, idx) {
                int cumulative = 0;
                for (final key in keys) {
                  if (idx == cumulative) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(top: 12, bottom: 6),
                      child: Text(
                        key,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary),
                      ),
                    );
                  }
                  cumulative++;
                  final items = grouped[key]!;
                  if (idx < cumulative + items.length) {
                    final expense = items[idx - cumulative];
                    // ✅ Wrap each tile with GestureDetector to show details
                    return GestureDetector(
                      onTap: () => _showTransactionDetail(expense),
                      child: ExpenseTile(
                        expense: expense,
                        onDelete: () => widget.onDelete(expense.id),
                      ),
                    );
                  }
                  cumulative += items.length;
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Row Widget ────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}