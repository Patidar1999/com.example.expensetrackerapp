import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'app_theme.dart';
import 'data_store.dart';
import 'expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _selectedCategory = 'Food';
  String _paymentMethod = 'UPI';
  bool _isIncome = false;
  DateTime _date = DateTime.now();
  bool _saving = false;

  final List<String> _paymentMethods = ['UPI', 'Cash', 'Card', 'Bank', 'Wallet'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and amount'), backgroundColor: AppTheme.expense),
      );
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount'), backgroundColor: AppTheme.expense),
      );
      return;
    }
    setState(() => _saving = true);
    final expense = Expense(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      amount: amount,
      category: _isIncome ? 'Other' : _selectedCategory,
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      paymentMethod: _paymentMethod,
      isIncome: _isIncome,
    );
    await DataStore.addExpense(expense);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Purple header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const Expanded(child: Center(child: Text('Add Expense', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)))),
                    const SizedBox(width: 36),
                  ],
                ),
                const SizedBox(height: 20),
                // Toggle income/expense
                Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      Expanded(child: _Toggle(label: 'Expense', active: !_isIncome, onTap: () => setState(() => _isIncome = false))),
                      Expanded(child: _Toggle(label: 'Income', active: _isIncome, onTap: () => setState(() => _isIncome = true))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Amount display
                Text(
                  _amountCtrl.text.isEmpty ? '₹ 0' : '₹ ${_amountCtrl.text}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(DateFormat('EEEE, MMM d yyyy').format(_date),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(color: AppTheme.bgPage),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount input
                    _InputCard(
                      label: 'Amount (₹)',
                      child: TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '0.00', hintStyle: TextStyle(color: AppTheme.textSecondary)),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    // Title
                    _InputCard(
                      label: 'Title',
                      child: TextField(
                        controller: _titleCtrl,
                        style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g. Zomato Order', hintStyle: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    ),
                    // Category
                    if (!_isIncome) ...[
                      const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.95,
                        children: kCategories.map((cat) {
                          final selected = _selectedCategory == cat.name;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat.name),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.primarySurface : AppTheme.bgCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected ? AppTheme.primary : AppTheme.borderColor,
                                  width: selected ? 1.5 : 0.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(cat.name, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Date
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
                            child: child!,
                          ),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                      child: _InputCard(
                        label: 'Date',
                        child: Row(
                          children: [
                            Text(DateFormat('MMM d, yyyy').format(_date),
                                style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    // Payment method
                    _InputCard(
                      label: 'Payment method',
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _paymentMethod,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                          items: _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                      ),
                    ),
                    // Note
                    _InputCard(
                      label: 'Note (optional)',
                      child: TextField(
                        controller: _noteCtrl,
                        style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Add a note...', hintStyle: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Save button
                    GestureDetector(
                      onTap: _saving ? null : _save,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: _saving
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text('Save Expense', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Toggle({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? AppTheme.primary : Colors.white70,
              )),
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _InputCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}
