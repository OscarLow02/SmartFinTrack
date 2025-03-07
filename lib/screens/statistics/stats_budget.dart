import 'package:flutter/material.dart';
import 'ViewMode.dart';
import 'stats_budget_settings.dart';

class StatsBudget extends StatefulWidget {
  const StatsBudget({
    super.key,
  });

  @override
  _StatsBudgetState createState() => _StatsBudgetState();
}

class _StatsBudgetState extends State<StatsBudget> {
  late String _selectedPeriod;
  late DateTime _selectedDate;
  String selectedPeriod = "Monthly"; // ✅ Default to Monthly
  double budgetLimit = 1500.00; // Example budget limit
  double spentAmount = 800.00; // Example spent amount
  double remainingAmount = 0.0;
  double progressPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = selectedPeriod;
    _selectedDate = DateTime.now(); // ✅ Start with the current date
    _calculateBudget();
  }

  void _calculateBudget() {
    setState(() {
      remainingAmount = budgetLimit - spentAmount;
      progressPercentage = budgetLimit > 0
          ? (spentAmount / budgetLimit).clamp(0.0, 1.0) * 100
          : 0;
    });
  }

  /// 🟢 Update Date based on ViewMode selection
  void _updateDate(DateTime newDate) {
    setState(() => _selectedDate = newDate);
  }

  /// 🟢 Convert DateTime to String for StatsPieChart
  String _formatDate(DateTime date) {
    return _selectedPeriod == "Monthly"
        ? "${ViewMode.getMonthName(date.month)} ${date.year}" // "Jun 2023"
        : "${date.year}"; // "2023"
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟢 ViewMode for Period & Date Selection
        ViewMode(
          selectedPeriod: _selectedPeriod,
          onPeriodChanged: (newValue) {
            setState(() {
              _selectedPeriod = newValue;
              _selectedDate = DateTime.now();
            });
          },
          onDateChanged: _updateDate,
          tabController: DefaultTabController.of(context),
          showTabs: false,
        ),

        // 🟢 Budget Overview Section
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // ✅ Upper Floor (Remaining Budget & Settings)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Remaining ($_selectedPeriod)",
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          "RM ${remainingAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20,
                            color:
                                remainingAmount < 0 ? Colors.red : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatsBudgetSettings(
                              selectedPeriod: _selectedPeriod,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Budget Setting >",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Lower Floor (Budget Limit & Progress Bar)
              Container(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    // Left: Budget Label & Limit
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPeriod,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            "RM ${budgetLimit.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    // Right: Progress Bar & Percentage
                    Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progressPercentage / 100,
                                child: Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: remainingAmount < 0
                                        ? Colors.red
                                        : Colors.blue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Spent: RM ${spentAmount.toStringAsFixed(2)}"),
                                Text(
                                    "Left: RM ${remainingAmount.toStringAsFixed(2)}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 🟢 Expenses by Category Group
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              _buildCategoryTile("Food & Drinks", 500.00),
              _buildCategoryTile("Shopping", 200.00),
              _buildCategoryTile("Entertainment", 100.00),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(String category, double amount) {
    return ListTile(
      title: Text(category),
      trailing: Text(
        "RM ${amount.toStringAsFixed(2)}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
