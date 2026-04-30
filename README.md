# 💰 Expense Tracker - Flutter App

A beautiful, fully functional expense tracker built with Flutter.

## 📱 Pages Included
- **Home** — Balance card, weekly chart, recent transactions
- **Add Expense** — Category picker, amount, date, payment method
- **Statistics** — Monthly trends, donut chart, category breakdown
- **Budget** — Per-category budget with progress bars
- **Transactions** — Search + filter by category, grouped by date
- **Profile** — Settings, dark mode toggle, currency picker

## 🚀 Setup Instructions

### 1. Prerequisites
- Flutter SDK installed → https://flutter.dev/docs/get-started/install
- Android Studio or VS Code with Flutter extension

### 2. Run the app

```bash
cd expense_tracker
flutter pub get
flutter run
```

### 3. Run on specific device
```bash
flutter run -d android     # Android emulator/device
flutter run -d ios         # iOS simulator (Mac only)
flutter run -d chrome      # Web browser
```

## 📦 Packages Used

| Package | Purpose |
|---------|---------|
| `fl_chart` | Bar chart & pie chart in Statistics |
| `intl` | Date & number formatting |
| `shared_preferences` | Local storage for expenses & budgets |
| `uuid` | Unique IDs for each expense |

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Colors, theme, categories
├── models/
│   ├── expense.dart             # Expense data model
│   ├── budget.dart              # Budget data model
│   └── data_store.dart          # SharedPreferences storage
├── screens/
│   ├── home_screen.dart         # Dashboard + bottom nav
│   ├── add_expense_screen.dart  # Add/edit expense form
│   ├── stats_screen.dart        # Charts & statistics
│   ├── budget_screen.dart       # Budget management
│   ├── transactions_screen.dart # All transactions list
│   └── profile_screen.dart      # Settings & profile
└── widgets/
    └── common_widgets.dart      # Reusable UI components
```

## 🎨 Design
- Primary color: Purple `#5B3FD4`
- Clean card-based UI
- Swipe to delete expenses and budgets
- Pull to refresh on home screen
- Demo data auto-loaded on first run

## 🔮 Future Improvements
- Cloud sync (Firebase)
- Multiple accounts
- Recurring expenses
- CSV export
- Widgets for home screen
