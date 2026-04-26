import 'package:expense_tracker/home_screen.dart';
import 'package:expense_tracker/login.dart';
import 'package:expense_tracker/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import 'app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: LoginPage(), // 👈 Use home instead of initialRoute
      routes: {
        'login': (context) => LoginPage(),
        'register': (context) => MyRegister(),
        'HomeScreen': (context) => HomeScreen(), // ✅ add this

      },
    );
  }
}