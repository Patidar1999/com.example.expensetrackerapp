import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'expense.dart'; // relative import — must match all other files

class DataStore {
  static const _expensesKey = 'expenses';
  static const _budgetsKey  = 'budgets';

  // ── Expenses ───────────────────────────────────────────────────────────────

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_expensesKey) ?? [];
    // Each element is a JSON string → decode to Map first
    return raw
        .map((e) => Expense.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    // Encode each Expense Map to a JSON string for SharedPreferences
    await prefs.setStringList(
      _expensesKey,
      expenses.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<void> addExpense(Expense expense) async {
    final list = await loadExpenses();
    list.add(expense);
    await saveExpenses(list);
  }

  static Future<void> deleteExpense(String id) async {
    final list = await loadExpenses();
    list.removeWhere((e) => e.id == id);
    await saveExpenses(list);
  }

  // ── Budgets ────────────────────────────────────────────────────────────────

  static Future<List<Budget>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_budgetsKey) ?? [];
    return raw
        .map((e) => Budget.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _budgetsKey,
      budgets.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  static Future<void> addBudget(Budget budget) async {
    final list = await loadBudgets();
    list.removeWhere((b) => b.category == budget.category);
    list.add(budget);
    await saveBudgets(list);
  }

  // ── Seed demo data (first run only) ───────────────────────────────────────

  static Future<void> seedDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('seeded') == true) return;

    final now = DateTime.now();

    final expenses = [
      Expense(
        id: '1',
        title: 'Salary Credit',
        amount: 68000,
        category: 'Other',
        date: now.subtract(const Duration(days: 1)),
        isIncome: true, paymentMethod: '',         // ← income flag required
      ),
      Expense(
        id: '2',
        title: 'Zomato Order',
        amount: 349,
        category: 'Food',
        date: now,
        isIncome: false, paymentMethod: '',
      ),
      Expense(
        id: '3',
        title: 'Metro Card',
        amount: 50,
        category: 'Travel',
        date: now,
        isIncome: false, paymentMethod: '',
      ),
      Expense(
        id: '4',
        title: 'Amazon',
        amount: 1299,
        category: 'Shopping',
        date: now.subtract(const Duration(days: 1)),
        isIncome: false, paymentMethod: '',
      ),
      Expense(
        id: '5',
        title: 'Starbucks',
        amount: 450,
        category: 'Food',
        date: now.subtract(const Duration(days: 1)),
        isIncome: false, paymentMethod: '',        // was null — fixed to false
      ),
      Expense(
        id: '6',
        title: 'Netflix',
        amount: 649,
        category: 'Entertainment',
        date: now.subtract(const Duration(days: 2)),
        isIncome: false, paymentMethod: '',
      ),
      Expense(
        id: '7',
        title: 'Ola Cab',
        amount: 220,
        category: 'Travel',
        date: now.subtract(const Duration(days: 2)),
        isIncome: false, paymentMethod: '',
      ),
      Expense(
        id: '8',
        title: 'Grocery',
        amount: 2100,
        category: 'Food',
        date: now.subtract(const Duration(days: 3)),
        isIncome: false, paymentMethod: '',
      ),
      Expense(
        id: '9',
        title: 'Gym Membership',
        amount: 1500,
        category: 'Health',
        date: now.subtract(const Duration(days: 4)),
        isIncome: false, paymentMethod: '',
      ),
      Expense(
        id: '10',
        title: 'Book: Clean Code',
        amount: 599,
        category: 'Education',
        date: now.subtract(const Duration(days: 5)),
        isIncome: false, paymentMethod: '',
      ),
    ];

    final budgets = [
      Budget(id: 'b1', category: 'Food',          limit: 10000),
      Budget(id: 'b2', category: 'Travel',        limit: 8000),
      Budget(id: 'b3', category: 'Shopping',      limit: 7000),
      Budget(id: 'b4', category: 'Entertainment', limit: 5000),
      Budget(id: 'b5', category: 'Health',        limit: 10000),
    ];

    await saveExpenses(expenses);
    await saveBudgets(budgets);
    await prefs.setBool('seeded', true);
  }
}