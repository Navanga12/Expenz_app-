import 'package:expenz/models/expence_model.dart';
import 'package:expenz/utils/colors.dart';
import 'package:expenz/utils/constants.dart';
import 'package:expenz/widgets/custum_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  final Function(Expense) onUpdateExpense;

  const EditExpenseScreen({
    super.key,
    required this.expense,
    required this.onUpdateExpense,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late ExpenseCategory _expenseCategory;
  late DateTime _selectedDate;
  late DateTime _selectedTime;

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _expenseCategory = widget.expense.category;
    _selectedDate = widget.expense.date;
    _selectedTime = widget.expense.time;

    _titleController = TextEditingController(text: widget.expense.title);
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.expense.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final double? parsedAmount = double.tryParse(_amountController.text.trim());
      if (parsedAmount == null || parsedAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid amount greater than 0"),
            backgroundColor: kRed,
          ),
        );
        return;
      }

      final Expense updatedExpense = Expense(
        id: widget.expense.id,
        title: _titleController.text.trim(),
        amount: parsedAmount,
        category: _expenseCategory,
        date: _selectedDate,
        time: _selectedTime,
        description: _descriptionController.text.trim(),
      );

      widget.onUpdateExpense(updatedExpense);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kRed,
      appBar: AppBar(
        backgroundColor: kRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Expense",
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefalutPadding,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Amount",
                      style: TextStyle(
                        color: kLightGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          "\$ ",
                          style: TextStyle(
                            fontSize: 48,
                            color: kWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              fontSize: 48,
                              color: kWhite,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              hintText: "0.0",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.white54,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(kDefalutPadding),
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  color: kWhite,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      DropdownButtonFormField<ExpenseCategory>(
                        decoration: InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                        initialValue: _expenseCategory,
                        icon: const Icon(
                          Icons.arrow_drop_down_circle_outlined,
                        ),
                        items: ExpenseCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Image.asset(
                                  expenseCategoryImages[category]!,
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  category.name[0].toUpperCase() +
                                      category.name.substring(1),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _expenseCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _titleController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please enter a title";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Title",
                          hintText: "Title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Description (Optional)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: kMainColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    color: kWhite,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Select Date",
                                    style: TextStyle(
                                      color: kWhite,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            DateFormat.yMMMd().format(_selectedDate),
                            style: const TextStyle(
                              color: kGrey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(_selectedTime),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedTime = DateTime(
                                    _selectedDate.year,
                                    _selectedDate.month,
                                    _selectedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: kYellow,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    color: kWhite,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Select Time",
                                    style: TextStyle(
                                      color: kWhite,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            DateFormat.jm().format(_selectedTime),
                            style: const TextStyle(
                              color: kGrey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      const Divider(
                        color: kLightGrey,
                        thickness: 2,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _saveExpense,
                        child: const CustumButton(
                          buttonName: "Save Changes",
                          buttonColor: kRed,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
