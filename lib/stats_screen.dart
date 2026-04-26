import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'app_theme.dart';  // AppTheme + ExpenseCategory, kCategories, getCategoryByName
import 'expense.dart';    // Expense, SectionHeader

class StatsScreen extends StatefulWidget {
  final List<Expense> expenses;
  const StatsScreen({super.key, required this.expenses});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _selectedMonth = DateTime.now();
  int _touchedIndex = -1;

  List<Expense> get _monthExpenses => widget.expenses
      .where((e) =>
  !e.isIncome &&
      e.date.year == _selectedMonth.year &&
      e.date.month == _selectedMonth.month)
      .toList();

  double get _totalSpent =>
      _monthExpenses.fold(0, (s, e) => s + e.amount);

  Map<String, double> get _byCategory {
    final map = <String, double>{};
    for (final e in _monthExpenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  List<double> get _weeklyData {
    final weeks = [0.0, 0.0, 0.0, 0.0];
    for (final e in _monthExpenses) {
      final week = ((e.date.day - 1) / 7).floor().clamp(0, 3);
      weeks[week] += e.amount;
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final fmt     = NumberFormat('#,##0');
    final catData = _byCategory;
    final catColors = [
      AppTheme.primary,
      AppTheme.income,
      AppTheme.expense,
      AppTheme.warning,
      const Color(0xFF993556),
    ];
    final weeks   = _weeklyData;
    final maxWeek =
    weeks.isEmpty ? 1.0 : weeks.reduce((a, b) => a > b ? a : b);
    final totalIncome = widget.expenses
        .where((e) =>
    e.isIncome &&
        e.date.year == _selectedMonth.year &&
        e.date.month == _selectedMonth.month)
        .fold(0.0, (s, e) => s + e.amount);
    final txCount  = _monthExpenses.length;
    final avgDaily = _totalSpent == 0 ? 0.0 : _totalSpent / 30;

    return CustomScrollView(
      slivers: [
        // ── Header ────────────────────────────────────────────────────────────
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Statistics',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: _pickMonth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          Text(
                              DateFormat('MMM yyyy')
                                  .format(_selectedMonth),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          const SizedBox(width: 4),
                          const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 16),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                  children: [
                    _StatMini(
                        label: 'Total spent',
                        value: '₹${fmt.format(_totalSpent)}',
                        color: AppTheme.expense),
                    _StatMini(
                        label: 'Total income',
                        value: '₹${fmt.format(totalIncome)}',
                        color: AppTheme.income),
                    _StatMini(
                        label: 'Transactions',
                        value: '$txCount',
                        color: AppTheme.primary),
                    _StatMini(
                        label: 'Daily avg',
                        value: '₹${fmt.format(avgDaily)}',
                        color: AppTheme.warning),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Body ──────────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: AppTheme.bgPage,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Month selector pills
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    itemBuilder: (_, i) {
                      final m = DateTime(
                          DateTime.now().year,
                          DateTime.now().month - 5 + i);
                      final active =
                          m.month == _selectedMonth.month &&
                              m.year  == _selectedMonth.year;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedMonth = m),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? AppTheme.primary
                                : AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: active
                                    ? AppTheme.primary
                                    : AppTheme.borderColor),
                          ),
                          child: Text(
                            DateFormat('MMM').format(m),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: active
                                    ? Colors.white
                                    : AppTheme.textSecondary),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── Weekly bar chart ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly trend (by week)',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxWeek * 1.2,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                  sideTitles:
                                  SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles:
                                  SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles:
                                  SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) => Text(
                                    'W${val.toInt() + 1}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary),
                                  ),
                                ),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(
                              4,
                                  (i) => BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: weeks[i],
                                    color: i == 2
                                        ? AppTheme.primary
                                        : const Color(0xFFDED9F8),
                                    width: 28,
                                    borderRadius:
                                    BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Donut / pie chart ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'By category'),
                      const SizedBox(height: 12),
                      if (catData.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('No expenses this month',
                                style: TextStyle(
                                    color: AppTheme.textSecondary)),
                          ),
                        )
                      else
                        Row(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 35,
                                  // Fixed: pieTouchData (not touchData)
                                  pieTouchData: PieTouchData(
                                    touchCallback: (event, resp) {
                                      if (!event
                                          .isInterestedForInteractions ||
                                          resp?.touchedSection ==
                                              null) {
                                        setState(
                                                () => _touchedIndex = -1);
                                        return;
                                      }
                                      setState(() => _touchedIndex =
                                          resp!.touchedSection!
                                              .touchedSectionIndex);
                                    },
                                  ),
                                  sections: catData.entries
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final idx = entry.key;
                                    final e   = entry.value;
                                    final pct = _totalSpent == 0
                                        ? 0.0
                                        : (e.value / _totalSpent) * 100;
                                    final isTouched =
                                        idx == _touchedIndex;
                                    return PieChartSectionData(
                                      color: catColors[
                                      idx % catColors.length],
                                      value: e.value,
                                      title: isTouched
                                          ? '${pct.toStringAsFixed(0)}%'
                                          : '',
                                      radius: isTouched ? 45 : 38,
                                      titleStyle: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: catData.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final idx = entry.key;
                                  final e   = entry.value;
                                  final pct = _totalSpent == 0
                                      ? 0.0
                                      : (e.value / _totalSpent) * 100;
                                  final cat = getCategoryByName(e.key);
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8),
                                    child: Row(children: [
                                      Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                              color: catColors[idx %
                                                  catColors.length],
                                              shape: BoxShape.circle)),
                                      const SizedBox(width: 8),
                                      Text(
                                          '${cat.emoji} ${e.key}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color:
                                              AppTheme.textPrimary)),
                                      const Spacer(),
                                      Text(
                                          '${pct.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color:
                                              AppTheme.textPrimary)),
                                    ]),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickMonth() async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
                primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() =>
      _selectedMonth = DateTime(picked.year, picked.month));
    }
  }
}

// ── _StatMini ─────────────────────────────────────────────────────────────────

class _StatMini extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatMini(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color == AppTheme.expense
                      ? Colors.white
                      : Colors.white)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }
}