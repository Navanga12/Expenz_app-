import 'package:expenz/models/expence_model.dart';
import 'package:expenz/models/income_model.dart';
import 'package:expenz/utils/colors.dart';
import 'package:expenz/utils/constants.dart';
import 'package:expenz/widgets/custum_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddNewScreen extends StatefulWidget {
  final Function(Expense) addExpense;
  final Function(Income) addIcome;
  const AddNewScreen({
    super.key,
    required this.addExpense,
    required this.addIcome,
  });

  @override
  State<AddNewScreen> createState() => _AddNewScreenState();
}

class _AddNewScreenState extends State<AddNewScreen> {
  final _formKey = GlobalKey<FormState>();

  int _selected = 0;

  ExpenseCategory _expenceCategory = ExpenseCategory.health;
  IncomeCategory _incomeCategory = IncomeCategory.salary;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTime = DateTime.now();

  // Text controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final double amount = double.parse(_amountController.text.trim());

      if (_selected == 0) {
        Expense expense = Expense(
          id: DateTime.now().millisecondsSinceEpoch,
          title: _titleController.text.trim(),
          amount: amount,
          category: _expenceCategory,
          date: _selectedDate,
          time: _selectedTime,
          description: _descriptionController.text.trim(),
        );

        widget.addExpense(expense);
      } else {
        Income income = Income(
          id: DateTime.now().millisecondsSinceEpoch,
          title: _titleController.text.trim(),
          amount: amount,
          category: _incomeCategory,
          date: _selectedDate,
          time: _selectedTime,
          description: _descriptionController.text.trim(),
        );

        widget.addIcome(income);
      }

      // Clear text fields and reset
      _titleController.clear();
      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _selectedTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selected == 0 ? kRed : kGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: kDefalutPadding),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // Selector Row (Expense / Income)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: kDefalutPadding),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: kWhite,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selected = 0;
                              _titleController.clear();
                              _amountController.clear();
                              _descriptionController.clear();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: _selected == 1 ? kWhite : kRed,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 60),
                              child: Text(
                                "Expense",
                                style: TextStyle(
                                  color: _selected == 0 ? kWhite : kBlack,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selected = 1;
                              _titleController.clear();
                              _amountController.clear();
                              _descriptionController.clear();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: _selected == 0 ? kWhite : kGreen,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 60,
                              ),
                              child: Text(
                                "Income",
                                style: TextStyle(
                                  color: _selected == 1 ? kWhite : kBlack,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Live Amount Display
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: kDefalutPadding),
                  child: Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How Much?",
                          style: TextStyle(
                            color: kLightGrey.withValues(alpha: 0.8),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _amountController,
                          builder: (context, value, child) {
                            return Text(
                              "\$${value.text.isEmpty ? '0' : value.text}",
                              style: const TextStyle(
                                fontSize: 44,
                                color: kWhite,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Form Container
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.23),
                  padding: const EdgeInsets.all(kDefalutPadding),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: kWhite,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Category selector dropdown
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: "Category",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                          ),
                          initialValue: _selected == 0
                              ? _expenceCategory
                              : _incomeCategory,
                          icon: const Icon(
                            Icons.arrow_drop_down_circle_outlined,
                          ),
                          items: _selected == 0
                              ? ExpenseCategory.values.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          expenseCategoryImages[category]!,
                                          width: 20,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(category.name[0].toUpperCase() +
                                            category.name.substring(1)),
                                      ],
                                    ),
                                  );
                                }).toList()
                              : IncomeCategory.values.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          incomeCategoryImages[category]!,
                                          width: 20,
                                          height: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(category.name[0].toUpperCase() +
                                            category.name.substring(1)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          onChanged: (value) {
                            setState(() {
                              if (_selected == 0) {
                                _expenceCategory = value as ExpenseCategory;
                              } else {
                                _incomeCategory = value as IncomeCategory;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 15),

                        // Title field with validator
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
                            hintText: "e.g. Grocery, Lunch",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Amount field with numeric keyboard and validator
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter an amount";
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return "Please enter a valid amount greater than 0";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Amount",
                            hintText: "0.00",
                            prefixText: "\$ ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Description field (optional)
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: "Description (Optional)",
                            hintText: "Add any additional note",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Date picker
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                ).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedDate = value;
                                    });
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: kMainColor,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        color: kWhite,
                                        size: 20,
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

                        // Time picker
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      _selectedTime),
                                ).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedTime = DateTime(
                                        _selectedDate.year,
                                        _selectedDate.month,
                                        _selectedDate.day,
                                        value.hour,
                                        value.minute,
                                      );
                                    });
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: kYellow,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: kWhite,
                                        size: 20,
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
                        const SizedBox(height: 20),
                        const Divider(
                          color: kLightGrey,
                          thickness: 2,
                        ),
                        const SizedBox(height: 20),

                        // Add Button
                        GestureDetector(
                          onTap: _submitForm,
                          child: CustumButton(
                            buttonName:
                                _selected == 0 ? "Add Expense" : "Add Income",
                            buttonColor: _selected == 0 ? kRed : kGreen,
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
      ),
    );
  }
}
