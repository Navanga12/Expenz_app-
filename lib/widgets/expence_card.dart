import 'package:expenz/models/expence_model.dart';
import 'package:expenz/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenceCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final double amount;
  final ExpenseCategory category;
  final String description;
  final DateTime createdAt;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const ExpenceCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.category,
    required this.description,
    required this.createdAt,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    expenseCategoryImages[category]!,
                    width: 20,
                    height: 20,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(date),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "- \$${amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kRed,
                      ),
                    ),
                    Text(
                      DateFormat.jm().format(date),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (onTap != null || onEdit != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: kGrey,
                    ),
                    onPressed: onTap ?? onEdit,
                    tooltip: "Edit Expense",
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
