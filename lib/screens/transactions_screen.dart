import 'package:expenz/models/expence_model.dart';
import 'package:expenz/models/income_model.dart';
import 'package:expenz/screens/edit_expense_screen.dart';
import 'package:expenz/utils/colors.dart';
import 'package:expenz/utils/constants.dart';
import 'package:expenz/widgets/expence_card.dart';
import 'package:expenz/widgets/income_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  final List<Expense> expensesList;
  final void Function(Expense) onDismissedExpenses;
  final void Function(Expense) onUpdateExpense;

  final List<Income> incomeList;
  final void Function(Income) onDismissedIncome;

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const TransactionsScreen({
    super.key,
    required this.expensesList,
    required this.onDismissedExpenses,
    required this.onUpdateExpense,
    required this.incomeList,
    required this.onDismissedIncome,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  ExpenseCategory? _selectedCategory;
  DateTime? _selectedDate;

  List<Expense> get _filteredExpenses {
    return widget.expensesList.where((expense) {
      final matchesCategory =
          _selectedCategory == null || expense.category == _selectedCategory;
      final matchesDate = _selectedDate == null ||
          (expense.date.year == _selectedDate!.year &&
              expense.date.month == _selectedDate!.month &&
              expense.date.day == _selectedDate!.day);
      return matchesCategory && matchesDate;
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters =
        _selectedCategory != null || _selectedDate != null;
    final filteredExpenses = _filteredExpenses;

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefalutPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Financial Transactions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kMainColor,
                    ),
                  ),
                  if (hasActiveFilters)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear_all, size: 18, color: kRed),
                      label: const Text(
                        "Reset",
                        style: TextStyle(color: kRed, fontSize: 13),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),

              // Filter Controls
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kLightGrey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.filter_list, size: 18, color: kGrey),
                            SizedBox(width: 6),
                            Text(
                              "Filter Expenses",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kBlack,
                              ),
                            ),
                          ],
                        ),
                        // Date filter button
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedDate != null
                                  ? kMainColor
                                  : kWhite,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedDate != null
                                    ? kMainColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: _selectedDate != null
                                      ? kWhite
                                      : kGrey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedDate != null
                                      ? DateFormat.yMMMd().format(_selectedDate!)
                                      : "Filter Date",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedDate != null
                                        ? kWhite
                                        : kBlack,
                                  ),
                                ),
                                if (_selectedDate != null) ...[
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDate = null;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: kWhite,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text("All Categories"),
                            selected: _selectedCategory == null,
                            selectedColor: kMainColor,
                            labelStyle: TextStyle(
                              color: _selectedCategory == null
                                  ? kWhite
                                  : kBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ...ExpenseCategory.values.map((category) {
                            final isSelected = _selectedCategory == category;
                            final name = category.name[0].toUpperCase() +
                                category.name.substring(1);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                avatar: Image.asset(
                                  expenseCategoryImages[category]!,
                                  width: 16,
                                  height: 16,
                                ),
                                label: Text(name),
                                selected: isSelected,
                                selectedColor: expenseCategoryColors[category] ??
                                    kMainColor,
                                labelStyle: TextStyle(
                                  color: isSelected ? kWhite : kBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory =
                                        selected ? category : null;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Expenses Header with counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Expenses",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBlack,
                    ),
                  ),
                  Text(
                    "${filteredExpenses.length} of ${widget.expensesList.length}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: kGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (widget.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: kMainColor),
                        SizedBox(height: 12),
                        Text(
                          "Loading expenses...",
                          style: TextStyle(color: kGrey),
                        ),
                      ],
                    ),
                  ),
                )
              else if (widget.errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off, size: 40, color: kRed),
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
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No expenses recorded yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Tap '+' below to add your first expense",
                          style: TextStyle(fontSize: 13, color: kGrey),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filteredExpenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: kGrey,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "No expenses match the selected filter.",
                          style: TextStyle(fontSize: 15, color: kGrey),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text("Clear Filter"),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return Dismissible(
                      key: ValueKey("expense_${expense.id}"),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: kRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: kWhite,
                        ),
                      ),
                      onDismissed: (direction) {
                        widget.onDismissedExpenses(expense);
                      },
                      child: ExpenceCard(
                        title: expense.title,
                        date: expense.date,
                        amount: expense.amount,
                        category: expense.category,
                        description: expense.description,
                        createdAt: expense.time,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditExpenseScreen(
                                expense: expense,
                                onUpdateExpense: widget.onUpdateExpense,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              // Income Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Income",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBlack,
                    ),
                  ),
                  Text(
                    "${widget.incomeList.length} items",
                    style: const TextStyle(
                      fontSize: 13,
                      color: kGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Show Incomes List
              if (widget.incomeList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "No incomes added yet.",
                      style: TextStyle(fontSize: 15, color: kGrey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.incomeList.length,
                  itemBuilder: (context, index) {
                    final income = widget.incomeList[index];
                    return Dismissible(
                      key: ValueKey("income_${income.id}"),
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: kRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: kWhite,
                        ),
                      ),
                      onDismissed: (direction) {
                        widget.onDismissedIncome(income);
                      },
                      child: IncomeCard(
                        title: income.title,
                        date: income.date,
                        amount: income.amount,
                        category: income.category,
                        description: income.description,
                        createdAt: income.time,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
