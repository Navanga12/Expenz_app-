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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final text = _searchController.text.trim().toLowerCase();
      if (_searchQuery != text) {
        setState(() {
          _searchQuery = text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Expense> get _filteredExpenses {
    return widget.expensesList.where((expense) {
      final matchesCategory =
          _selectedCategory == null || expense.category == _selectedCategory;
      final matchesDate = _selectedDate == null ||
          (expense.date.year == _selectedDate!.year &&
              expense.date.month == _selectedDate!.month &&
              expense.date.day == _selectedDate!.day);
      final matchesSearch = _searchQuery.isEmpty ||
          expense.title.toLowerCase().contains(_searchQuery) ||
          expense.description.toLowerCase().contains(_searchQuery) ||
          expense.category.name.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesDate && matchesSearch;
    }).toList();
  }

  List<Income> get _filteredIncomes {
    return widget.incomeList.where((income) {
      final matchesSearch = _searchQuery.isEmpty ||
          income.title.toLowerCase().contains(_searchQuery) ||
          income.description.toLowerCase().contains(_searchQuery) ||
          income.category.name.toLowerCase().contains(_searchQuery);
      return matchesSearch;
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
      _searchController.clear();
      _searchQuery = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasActiveFilters =
        _selectedCategory != null || _selectedDate != null || _searchQuery.isNotEmpty;
    final filteredExpenses = _filteredExpenses;
    final filteredIncomes = _filteredIncomes;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Theme.of(context).cardColor : kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty
                        ? kMainColor
                        : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                    width: _searchQuery.isNotEmpty ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : kBlack,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search by title, note, or category...",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey.shade500 : kGrey,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: kMainColor,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: kGrey),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.manage_search, size: 16, color: kMainColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Filtering by \"${_searchController.text.trim()}\"",
                          style: const TextStyle(
                            fontSize: 13,
                            color: kMainColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: const Text(
                          "Clear",
                          style: TextStyle(
                            fontSize: 12,
                            color: kRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 15),

              // Filter Controls
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).cardColor
                      : kLightGrey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.filter_list, size: 18, color: kGrey),
                            const SizedBox(width: 6),
                            Text(
                              "Filter Expenses",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : kBlack,
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
                                  : (isDark ? const Color(0xFF2C2C2C) : kWhite),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedDate != null
                                    ? kMainColor
                                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: _selectedDate != null
                                      ? kWhite
                                      : (isDark ? Colors.white70 : kGrey),
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
                                        : (isDark ? Colors.white : kBlack),
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
                                  : (isDark ? Colors.white70 : kBlack),
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
                                  color: isSelected
                                      ? kWhite
                                      : (isDark ? Colors.white70 : kBlack),
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
                  Text(
                    "Expenses",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : kBlack,
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
                        Text(
                          "No expenses recorded yet",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : kBlack,
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
                          size: 44,
                          color: kGrey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? "No expenses found matching \"${_searchController.text.trim()}\""
                              : "No expenses match the selected filter.",
                          style: const TextStyle(fontSize: 15, color: kGrey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear, size: 16),
                          label: Text(
                            _searchQuery.isNotEmpty
                                ? "Clear Search"
                                : "Clear Filter",
                          ),
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
                  Text(
                    "Income",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : kBlack,
                    ),
                  ),
                  Text(
                    "${filteredIncomes.length} of ${widget.incomeList.length}",
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
              else if (filteredIncomes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 36,
                          color: kGrey,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "No income matching \"${_searchController.text.trim()}\"",
                          style: const TextStyle(fontSize: 14, color: kGrey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredIncomes.length,
                  itemBuilder: (context, index) {
                    final income = filteredIncomes[index];
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
