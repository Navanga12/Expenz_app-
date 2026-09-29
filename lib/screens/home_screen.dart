import 'package:expenz/models/expence_model.dart';
import 'package:expenz/models/income_model.dart';
import 'package:expenz/screens/edit_expense_screen.dart';
import 'package:expenz/services/theme_service.dart';
import 'package:expenz/services/user_details_service.dart';
import 'package:expenz/utils/colors.dart';
import 'package:expenz/utils/constants.dart';
import 'package:expenz/widgets/expence_card.dart';
import 'package:expenz/widgets/income_exp_chip.dart';
import 'package:expenz/widgets/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final List<Expense> expensesList;
  final List<Income> incomeList;
  final void Function(Expense)? onUpdateExpense;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const HomeScreen({
    super.key,
    required this.expensesList,
    this.incomeList = const [],
    this.onUpdateExpense,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  String email = "";
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    // Get user details from shared preferences
    UserService.getUserDetails().then((value) {
      if (value['username'] != null && value['email'] != null) {
        setState(() {
          username = value['username']!;
          email = value['email']!;
        });
      }
    });
  }

  // Calculate dynamic monthly expenses for the selected month
  double get totalMonthlyExpenses {
    return widget.expensesList
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  // Calculate dynamic monthly income for the selected month
  double get totalMonthlyIncome {
    return widget.incomeList
        .where((i) =>
            i.date.year == _selectedMonth.year &&
            i.date.month == _selectedMonth.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Welcome and Month Summary Container
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? kMainColor.withValues(alpha: 0.25)
                      : kMainColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(kDefalutPadding),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: kMainColor,
                              border: Border.all(
                                color: kMainColor,
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.asset(
                                "assets/images/user.jpg",
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Welcome $username",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : kBlack,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: ThemeService.themeNotifier,
                            builder: (context, mode, _) {
                              final darkModeActive = mode == ThemeMode.dark;
                              return IconButton(
                                tooltip: darkModeActive
                                    ? "Switch to Light Mode"
                                    : "Switch to Dark Mode",
                                icon: Icon(
                                  darkModeActive
                                      ? Icons.light_mode
                                      : Icons.dark_mode_outlined,
                                  color: kMainColor,
                                  size: 26,
                                ),
                                onPressed: () {
                                  ThemeService.toggleTheme(!darkModeActive);
                                },
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: kMainColor,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Month Selector Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Theme.of(context).cardColor : kWhite,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                size: 22,
                                color: kMainColor,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  _selectedMonth = DateTime(
                                    _selectedMonth.year,
                                    _selectedMonth.month - 1,
                                  );
                                });
                              },
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  size: 16,
                                  color: kMainColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat.yMMMM().format(_selectedMonth),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : kBlack,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isCurrentMonth) ...[
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedMonth = DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                        );
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            kMainColor.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Current",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: kMainColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    size: 22,
                                    color: kMainColor,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() {
                                      _selectedMonth = DateTime(
                                        _selectedMonth.year,
                                        _selectedMonth.month + 1,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Dynamic Income and Expense Chips for Selected Month
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IncomeExpenceChip(
                            title: "Income",
                            amount: totalMonthlyIncome,
                            bgColor: kGreen,
                            imageUrl: "assets/images/income.png",
                          ),
                          IncomeExpenceChip(
                            title: "Expense",
                            amount: totalMonthlyExpenses,
                            bgColor: kRed,
                            imageUrl: "assets/images/expense.png",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Spend frequency
              const Padding(
                padding: EdgeInsets.all(kDefalutPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Spend Frequency",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20),
                    LineChartSample(),
                  ],
                ),
              ),

              // Recent transactions
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefalutPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : kBlack,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (widget.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: kMainColor),
                              SizedBox(height: 12),
                              Text(
                                "Loading transactions...",
                                style: TextStyle(color: kGrey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_off, size: 36, color: kRed),
                              const SizedBox(height: 8),
                              Text(
                                widget.errorMessage!,
                                style: const TextStyle(color: kGrey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              if (widget.onRetry != null)
                                ElevatedButton.icon(
                                  onPressed: widget.onRetry,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text("Retry"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kMainColor,
                                    foregroundColor: kWhite,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.expensesList.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "No expenses recorded yet",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : kBlack,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Tap the '+' button below to add your first expense",
                                style: TextStyle(fontSize: 13, color: kGrey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.expensesList.length,
                        itemBuilder: (context, index) {
                          final expense = widget.expensesList[index];
                          return ExpenceCard(
                            title: expense.title,
                            date: expense.date,
                            amount: expense.amount,
                            category: expense.category,
                            description: expense.description,
                            createdAt: expense.time,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditExpenseScreen(
                                    expense: expense,
                                    onUpdateExpense: (updated) {
                                      widget.onUpdateExpense?.call(updated);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
