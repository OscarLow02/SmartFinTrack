import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/statistics/stats_linegraph.dart';

class StatsPieChart extends StatelessWidget {
  final String title; // "Income" or "Expenses"
  final List<String> categories;
  final List<double> amounts;
  final List<int> percentages;
  final Color defaultColor;
  final String selectedDate; // 🆕 Selected Date
  final String selectedPeriod; // 🆕 Selected Period

  const StatsPieChart({
    super.key,
    required this.title,
    required this.categories,
    required this.amounts,
    required this.percentages,
    this.defaultColor = Colors.red,
    required this.selectedDate, // 🆕 Initialize in constructor
    required this.selectedPeriod, // 🆕 Initialize in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          // 🟢 Pie Chart Placeholder
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(child: Text("Pie Chart ($title)")),
          ),

          const SizedBox(height: 20), // Spacing

          // 🟢 Category List
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 5.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatsLineGraph(
                            categoryGroup:
                                categories[index], // Existing parameter
                            selectedDate:
                                selectedDate, // New: Pass selected date
                            selectedPeriod:
                                selectedPeriod, // New: Pass period type
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 🟢 Percentage Box (Colored)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color:
                                  defaultColor.withOpacity(0.7), // Customizable
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              "${percentages[index]}%",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12), // Spacing

                          // 🟢 Category Name
                          Expanded(
                            child: Text(
                              categories[index],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          // 🟢 Amount (Currency)
                          Text(
                            "RM ${amounts[index].toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
