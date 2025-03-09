import 'package:flutter/material.dart';
import 'stats_budget_settings_set.dart';

class StatsBudgetSettings extends StatelessWidget {
  final String selectedPeriod;

  const StatsBudgetSettings({super.key, required this.selectedPeriod});

  @override
  Widget build(BuildContext context) {
    final bool isMonthly = selectedPeriod == "Monthly";
    final List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    final int currentYear = DateTime.now().year;
    final List<int> yearRange =
        List.generate(11, (index) => currentYear - 5 + index);

    return Scaffold(
      appBar: AppBar(title: const Text("Budget Limit")),
      body: Column(
        children: [
          // 🟢 Default Budget List Tile
          const ListTile(
            title: Text("Default Budget"),
            trailing: Text("RM 1,500.00"), // Example default budget
          ),
          const Divider(),

          // 🟢 Display Monthly or Yearly Budget List
          Expanded(
            child: ListView.builder(
              itemCount: isMonthly ? months.length : yearRange.length,
              itemBuilder: (context, index) {
                final String label =
                    isMonthly ? months[index] : yearRange[index].toString();
                return ListTile(
                  title: Text(label),
                  trailing: Text("RM 1,500.00"), // Example budget limit
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatsBudgetSettingsSet(
                          title: isMonthly ? "$label $currentYear" : label,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
