import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'app_theme.dart';  // AppTheme + ExpenseCategory, kCategories, getCategoryByName
import 'data_store.dart';
import 'expense.dart';    // Expense, Budget

class BudgetScreen extends StatefulWidget {
  final List<Expense> expenses;
  const BudgetScreen({super.key, required this.expenses});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Budget> _budgets = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = await DataStore.loadBudgets();
    if (mounted) setState(() => _budgets = b);
  }

  double _spent(String category) {
    final now = DateTime.now();
    return widget.expenses
        .where((e) =>
    !e.isIncome &&
        e.category == category &&
        e.date.month == now.month &&
        e.date.year == now.year)
        .fold(0, (s, e) => s + e.amount);
  }

  double get _totalBudget => _budgets.fold(0, (s, b) => s + b.limit);
  double get _totalSpent  => _budgets.fold(0, (s, b) => s + _spent(b.category));

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    final usedPct =
    _totalBudget == 0 ? 0.0 : (_totalSpent / _totalBudget).clamp(0.0, 1.0);
    final left = _totalBudget - _totalSpent;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Budget',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: _showAddBudget,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(children: [
                          Icon(Icons.add, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('New',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total budget used',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(
                          '₹${fmt.format(_totalSpent)} / ₹${fmt.format(_totalBudget)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: usedPct,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            usedPct > 0.9
                                ? const Color(0xFFFF7EB3)
                                : const Color(0xFF5CFFC0),
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(usedPct * 100).toStringAsFixed(0)}% used  ·  ₹${fmt.format(left < 0 ? 0 : left)} left',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                final budget = _budgets[i];
                final spent  = _spent(budget.category);
                final pct    = budget.limit == 0
                    ? 0.0
                    : (spent / budget.limit).clamp(0.0, 1.0);
                final cat    = getCategoryByName(budget.category);

                Color barColor = AppTheme.income;
                if (pct > 0.9)      barColor = AppTheme.expense;
                else if (pct > 0.7) barColor = AppTheme.warning;

                return Dismissible(
                  key: Key(budget.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) async {
                    final updated =
                    _budgets.where((b) => b.id != budget.id).toList();
                    await DataStore.saveBudgets(updated);
                    _load();
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.expense.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: AppTheme.expense),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(cat.emoji,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(budget.category,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary)),
                            ),
                            Text(
                                '₹${fmt.format(spent)} / ₹${fmt.format(budget.limit)}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppTheme.borderColor,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(barColor),
                            minHeight: 7,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                                '${(pct * 100).toStringAsFixed(0)}% used',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary)),
                            const Spacer(),
                            if (pct > 0.9)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.expense
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Almost over!',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: AppTheme.expense,
                                        fontWeight: FontWeight.w500)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _budgets.length,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddBudget() {
    String? selectedCat = kCategories.first.name;
    final limitCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Set budget',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              const Text('Category',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCat,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: AppTheme.borderColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
                items: kCategories
                    .map((c) => DropdownMenuItem(
                    value: c.name,
                    child: Text('${c.emoji} ${c.name}')))
                    .toList(),
                onChanged: (v) => setS(() => selectedCat = v),
              ),
              const SizedBox(height: 12),
              const Text('Monthly limit (₹)',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: limitCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: AppTheme.borderColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  hintText: 'e.g. 5000',
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final limit = double.tryParse(limitCtrl.text);
                  if (limit == null || selectedCat == null) return;
                  await DataStore.addBudget(Budget(
                      id: const Uuid().v4(),
                      category: selectedCat!,
                      limit: limit));
                  if (context.mounted) Navigator.pop(context);
                  _load();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Save Budget',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}