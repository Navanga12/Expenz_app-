import 'package:expenz/models/expence_model.dart';
import 'package:expenz/models/income_model.dart';
import 'package:expenz/screens/transactions_screen.dart';
import 'package:expenz/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeService Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ThemeService.initTheme();
    });

    test('Initial theme defaults to light mode', () {
      expect(ThemeService.isDarkMode, isFalse);
      expect(ThemeService.themeNotifier.value, ThemeMode.light);
    });

    test('toggleTheme switches to dark mode and persists to SharedPreferences', () async {
      await ThemeService.toggleTheme(true);
      expect(ThemeService.isDarkMode, isTrue);
      expect(ThemeService.themeNotifier.value, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), isTrue);

      await ThemeService.toggleTheme(false);
      expect(ThemeService.isDarkMode, isFalse);
      expect(ThemeService.themeNotifier.value, ThemeMode.light);
      expect(prefs.getBool('isDarkMode'), isFalse);
    });

    test('initTheme restores dark mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': true});
      await ThemeService.initTheme();
      expect(ThemeService.isDarkMode, isTrue);
      expect(ThemeService.themeNotifier.value, ThemeMode.dark);
    });
  });

  group('TransactionsScreen Keyword Search Tests', () {
    final sampleExpenses = [
      Expense(
        id: 1,
        title: 'Grocery shopping',
        amount: 45.50,
        category: ExpenseCategory.food,
        date: DateTime(2026, 9, 15),
        time: DateTime(2026, 9, 15, 10, 30),
        description: 'Milk, eggs, and bread',
      ),
      Expense(
        id: 2,
        title: 'Train ticket',
        amount: 12.00,
        category: ExpenseCategory.transport,
        date: DateTime(2026, 9, 16),
        time: DateTime(2026, 9, 16, 8, 15),
        description: 'Commute to work',
      ),
      Expense(
        id: 3,
        title: 'Doctor prescription',
        amount: 30.00,
        category: ExpenseCategory.health,
        date: DateTime(2026, 9, 17),
        time: DateTime(2026, 9, 17, 14, 0),
        description: 'Vitamins and medicine',
      ),
    ];

    final sampleIncomes = [
      Income(
        id: 1,
        title: 'Monthly Salary',
        amount: 2500.0,
        category: IncomeCategory.salary,
        date: DateTime(2026, 9, 1),
        time: DateTime(2026, 9, 1, 9, 0),
        description: 'Regular payroll',
      ),
    ];

    Widget createTestWidget() {
      return MaterialApp(
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        home: TransactionsScreen(
          expensesList: sampleExpenses,
          onDismissedExpenses: (_) {},
          onUpdateExpense: (_) {},
          incomeList: sampleIncomes,
          onDismissedIncome: (_) {},
        ),
      );
    }

    testWidgets('Displays search bar with placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.text('Search by title, note, or category...'),
        findsOneWidget,
      );
      expect(find.text('Grocery shopping'), findsOneWidget);
      expect(find.text('Train ticket'), findsOneWidget);
      expect(find.text('Doctor prescription'), findsOneWidget);
    });

    testWidgets('Filters expenses by title keyword', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter search term "Grocery"
      await tester.enterText(find.byType(TextField), 'Grocery');
      await tester.pumpAndSettle();

      expect(find.text('Grocery shopping'), findsOneWidget);
      expect(find.text('Train ticket'), findsNothing);
      expect(find.text('Doctor prescription'), findsNothing);
      expect(find.text('1 of 3'), findsOneWidget);
    });

    testWidgets('Filters expenses by note/description keyword', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter search term "medicine" (found in description)
      await tester.enterText(find.byType(TextField), 'medicine');
      await tester.pumpAndSettle();

      expect(find.text('Doctor prescription'), findsOneWidget);
      expect(find.text('Grocery shopping'), findsNothing);
      expect(find.text('Train ticket'), findsNothing);
    });

    testWidgets('Shows empty state when no results match', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'NonexistentKeywordXYZ');
      await tester.pumpAndSettle();

      expect(find.text('No expenses found matching "NonexistentKeywordXYZ"'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);

      // Tap Clear Search button
      await tester.tap(find.text('Clear Search'));
      await tester.pumpAndSettle();

      // All expenses restored
      expect(find.text('Grocery shopping'), findsOneWidget);
      expect(find.text('Train ticket'), findsOneWidget);
      expect(find.text('Doctor prescription'), findsOneWidget);
    });

    testWidgets('Clear button in search field resets query', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Train');
      await tester.pumpAndSettle();

      expect(find.text('Train ticket'), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Grocery shopping'), findsOneWidget);
      expect(find.text('Train ticket'), findsOneWidget);
    });
  });
}
