import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_expense_screen.dart';
import 'app_theme.dart';
import 'data_store.dart';
import 'expense.dart';
import 'transactions_screen.dart';
import 'stats_screen.dart';
import 'budget_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Expense> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await DataStore.seedDemoData();
    final data = await DataStore.loadExpenses();
    if (mounted) setState(() { _expenses = data; _loading = false; });
  }

  double get _totalIncome => _expenses.where((e) => e.isIncome).fold(0, (s, e) => s + e.amount);
  double get _totalExpense => _expenses.where((e) => !e.isIncome).fold(0, (s, e) => s + e.amount);
  double get _balance => _totalIncome - _totalExpense;

  List<double> get _weeklyData {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _expenses
          .where((e) => !e.isIncome &&
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day)
          .fold(0.0, (s, e) => s + e.amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardPage(
        expenses: _expenses,
        balance: _balance,
        totalIncome: _totalIncome,
        totalExpense: _totalExpense,
        weeklyData: _weeklyData,
        onRefresh: _loadData,
        onDeleteExpense: (id) async {
          await DataStore.deleteExpense(id);
          _loadData();
        },
      ),
      StatsScreen(expenses: _expenses),
      const SizedBox.shrink(),
      BudgetScreen(expenses: _expenses),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : pages[_currentIndex == 2 ? 0 : _currentIndex],
      floatingActionButton: _currentIndex == 2
          ? null
          : FloatingActionButton(
        backgroundColor: AppTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          _loadData();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', active: _currentIndex == 0, onTap: () => setState(() => _currentIndex = 0)),
              _NavItem(icon: Icons.bar_chart_rounded, label: 'Stats', active: _currentIndex == 1, onTap: () => setState(() => _currentIndex = 1)),
              const SizedBox(width: 48),
              _NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Budget', active: _currentIndex == 3, onTap: () => setState(() => _currentIndex = 3)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', active: _currentIndex == 4, onTap: () => setState(() => _currentIndex = 4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? AppTheme.primary : AppTheme.textSecondary, size: 19),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w500 : FontWeight.normal,
                  color: active ? AppTheme.primary : AppTheme.textSecondary,
                )),
            if (active)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4, height: 4,
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  final List<Expense> expenses;
  final double balance, totalIncome, totalExpense;
  final List<double> weeklyData;
  final VoidCallback onRefresh;
  final Function(String) onDeleteExpense;

  const _DashboardPage({
    required this.expenses, required this.balance, required this.totalIncome,
    required this.totalExpense, required this.weeklyData, required this.onRefresh,
    required this.onDeleteExpense,
  });

  // ✅ Get current Firebase user
  User? get _user => FirebaseAuth.instance.currentUser;

  // ✅ Dynamic display name from Firebase
  String get _displayName {
    if (_user == null) return 'User';
    final name = _user!.displayName ?? '';
    if (name.trim().isNotEmpty) return name.trim();

    // Fallback: derive from email prefix (e.g. shubham.patidar@gmail.com → Shubham Patidar)
    final email = _user!.email ?? '';
    if (email.isEmpty) return 'User';
    final prefix = email.split('@').first;
    return prefix
        .split(RegExp(r'[._\-]'))
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  // ✅ Avatar initials (e.g. "Shubham Patidar" → "SP")
  String get _initials {
    final parts = _displayName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    if (parts.isNotEmpty && parts.first.length >= 2) {
      return parts.first.substring(0, 2).toUpperCase();
    }
    return 'U';
  }

  // ✅ Time-based greeting
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  // ✅ Greeting emoji based on time
  String get _greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    if (hour < 21) return '🌆';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final recent = expenses.take(5).toList();
    final fmt = (double v) => '₹${NumberFormat('#,##0').format(v)}';
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxVal = weeklyData.isEmpty ? 1.0 : weeklyData.reduce((a, b) => a > b ? a : b);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppTheme.primary,
      child: CustomScrollView(
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
                bottom: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // ✅ Dynamic avatar with initials
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white38, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // ✅ Dynamic greeting + name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _greeting,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(_greetingEmoji, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          Text(
                            _displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Balance card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Balance',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(fmt(balance),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _BalancePill(
                                label: 'Income',
                                value: fmt(totalIncome),
                                dotColor: const Color(0xFF5CFFC0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BalancePill(
                                label: 'Expenses',
                                value: fmt(totalExpense),
                                dotColor: const Color(0xFFFF7EB3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.bgPage,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    // Quick actions
                    Row(
                      children: [
                        _QuickBtn(
                          emoji: '➕',
                          label: 'Add',
                          bg: AppTheme.primarySurface,
                          onTap: () async {
                            await Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
                            onRefresh();
                          },
                        ),
                        _QuickBtn(emoji: '📊', label: 'Stats', bg: const Color(0xFFE1F5EE), onTap: () {}),
                        _QuickBtn(emoji: '📂', label: 'Budget', bg: const Color(0xFFFAEEDA), onTap: () {}),
                        _QuickBtn(
                          emoji: '↗',
                          label: 'Export',
                          bg: const Color(0xFFFAECE7),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionsScreen(
                                    expenses: expenses, onDelete: onDeleteExpense),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Weekly chart
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Weekly spending',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 80,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(7, (i) {
                                final val = weeklyData[i];
                                final h = maxVal == 0 ? 0.0 : (val / maxVal) * 55;
                                final isToday = i == 6;
                                return Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: h > 0 ? h : 4,
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? AppTheme.primary
                                              : const Color(0xFFDED9F8),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(days[i],
                                          style: const TextStyle(
                                              fontSize: 9,
                                              color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionHeader(
                      title: 'Recent transactions',
                      actionText: 'See all',
                      onAction: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionsScreen(
                              expenses: expenses, onDelete: onDeleteExpense),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) => ExpenseTile(
                  expense: recent[i],
                  onDelete: () => onDeleteExpense(recent[i].id),
                ),
                childCount: recent.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  final String label, value;
  final Color dotColor;
  const _BalancePill(
      {required this.label, required this.value, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 6,
                height: 6,
                decoration:
                BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ]),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String emoji, label;
  final Color bg;
  final VoidCallback onTap;
  const _QuickBtn(
      {required this.emoji,
        required this.label,
        required this.bg,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(10)),
                child:
                Center(child: Text(emoji, style: const TextStyle(fontSize: 15))),
              ),
              const SizedBox(height: 5),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}