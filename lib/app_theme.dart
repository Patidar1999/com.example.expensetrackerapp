import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF5B3FD4);
  static const Color primaryLight = Color(0xFF7C5CE0);
  static const Color primarySurface = Color(0xFFEEEDFE);
  static const Color income = Color(0xFF1D9E75);
  static const Color expense = Color(0xFFE24B4A);
  static const Color warning = Color(0xFFEF9F27);
  static const Color bgPage = Color(0xFFF4F6FB);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFECE9F5);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF9E9EB2);
  static const Color textMuted = Color(0xFF6B6A80);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: bgPage,
    ),
    scaffoldBackgroundColor: bgPage,
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}

// ── Category model ────────────────────────────────────────────────────────────

class ExpenseCategory {
  final String name;
  final String emoji;
  final Color color;
  final Color bgColor;

  const ExpenseCategory({
    required this.name,
    required this.emoji,
    required this.color,
    required this.bgColor,
  });
}

const List<ExpenseCategory> kCategories = [
  ExpenseCategory(name: 'Food',          emoji: '🍔', color: Color(0xFFBA7517), bgColor: Color(0xFFFFF3E0)),
  ExpenseCategory(name: 'Travel',        emoji: '🚌', color: Color(0xFF185FA5), bgColor: Color(0xFFE3F2FD)),
  ExpenseCategory(name: 'Shopping',      emoji: '🛍',  color: Color(0xFF993556), bgColor: Color(0xFFFCE4EC)),
  ExpenseCategory(name: 'Health',        emoji: '🏥', color: Color(0xFF1D9E75), bgColor: Color(0xFFE8F5E9)),
  ExpenseCategory(name: 'Entertainment', emoji: '🎬', color: Color(0xFF534AB7), bgColor: Color(0xFFF3E5F5)),
  ExpenseCategory(name: 'Education',     emoji: '📚', color: Color(0xFF185FA5), bgColor: Color(0xFFE8EAF6)),
  ExpenseCategory(name: 'Home',          emoji: '🏠', color: Color(0xFF854F0B), bgColor: Color(0xFFFFF8E1)),
  ExpenseCategory(name: 'Other',         emoji: '➕', color: Color(0xFF5F5E5A), bgColor: Color(0xFFF1EFE8)),
];

ExpenseCategory getCategoryByName(String name) {
  return kCategories.firstWhere(
        (c) => c.name == name,
    orElse: () => kCategories.last,
  );
}