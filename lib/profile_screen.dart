import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;
  String _currency = 'INR (₹)';
  String _userName= "";
  String _userEmail= "";


  void initState(){
    super.initState();
      _loadUserData();
  }


  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      _userName  = doc.data()?['name'] ?? user.displayName ?? 'User';
      _userEmail = user.email ?? '';
    });
  }


  @override
  Widget build(BuildContext context) {
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
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(height: 10),
                 Text(_userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(_userEmail,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _StatPill(
                        label: 'Transactions', value: '12'),
                    Container(
                        width: 0.5,
                        height: 28,
                        color: Colors.white30,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20)),
                    const _StatPill(label: 'Budgets', value: '5'),
                    Container(
                        width: 0.5,
                        height: 28,
                        color: Colors.white30,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20)),
                    const _StatPill(label: 'Since', value: 'Apr'),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _SectionLabel(label: 'ACCOUNT'),
              _ProfileRow(
                  emoji: '👤',
                  label: 'Edit profile',
                  bg: AppTheme.primarySurface,
                  onTap: () => _showSnack('Edit profile')),
              _ProfileRow(
                  emoji: '🔔',
                  label: 'Notifications',
                  bg: const Color(0xFFE1F5EE),
                  onTap: () => _showSnack('Notifications')),
              _ProfileRow(
                  emoji: '💳',
                  label: 'Payment methods',
                  bg: const Color(0xFFFAEEDA),
                  onTap: () => _showSnack('Payment methods')),
              const _SectionLabel(label: 'PREFERENCES'),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                          child: Text('🌙',
                              style: TextStyle(fontSize: 16))),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Text('Dark mode',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary))),
                    Switch(
                      value: _darkMode,
                      onChanged: (v) =>
                          setState(() => _darkMode = v),
                      activeColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                          child: Text('₹',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textPrimary))),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                        child: Text('Currency',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary))),
                    GestureDetector(
                      onTap: _pickCurrency,
                      child: Row(children: [
                        Text(_currency,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textSecondary,
                            size: 18),
                      ]),
                    ),
                  ],
                ),
              ),
              _ProfileRow(
                  emoji: '📤',
                  label: 'Export data',
                  bg: const Color(0xFFE8F5E9),
                  onTap: () => _showSnack('Exporting...')),
              const _SectionLabel(label: 'SUPPORT'),
              _ProfileRow(
                  emoji: '❓',
                  label: 'Help & feedback',
                  bg: const Color(0xFFF3E5F5),
                  onTap: () => _showSnack('Help')),
              _ProfileRow(
                  emoji: '🚪',
                  label: 'Log out',
                  bg: const Color(0xFFFFEBEE),
                  textColor: AppTheme.expense,
                  onTap: _confirmLogout),
            ]),
          ),
        ),
      ],
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _pickCurrency() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          'INR (₹)',
          'USD (\$)',
          'EUR (€)',
          'GBP (£)',
          'JPY (¥)',
        ]
            .map((c) => ListTile(
          title: Text(c),
          trailing: _currency == c
              ? const Icon(Icons.check,
              color: AppTheme.primary)
              : null,
          onTap: () {
            setState(() => _currency = c);
            Navigator.pop(context);
          },
        ))
            .toList(),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out?'),
        content:
        const Text('Are you sure you want to log out?'),
        actions: [
          // Fixed: use onPressed instead of onTap
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false),
            child: const Text('Log out',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  const _StatPill({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500)),
    Text(label,
        style: const TextStyle(
            color: Colors.white60, fontSize: 10)),
  ]);
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Text(label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary)),
  );
}

class _ProfileRow extends StatelessWidget {
  final String emoji, label;
  final Color bg;
  final Color textColor;
  final VoidCallback onTap;
  const _ProfileRow({
    required this.emoji,
    required this.label,
    required this.bg,
    required this.onTap,
    this.textColor = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
              child: Text(emoji,
                  style: const TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor))),
        const Icon(Icons.chevron_right_rounded,
            color: AppTheme.textSecondary, size: 18),
      ]),
    ),
  );
}