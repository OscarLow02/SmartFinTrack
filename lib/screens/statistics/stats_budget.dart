import 'package:flutter/material.dart';
import 'ViewMode.dart';

class StatsBudget extends StatefulWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const StatsBudget({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  _StatsBudgetState createState() => _StatsBudgetState();
}

class _StatsBudgetState extends State<StatsBudget> {
  String selectedPeriod = "Monthly"; // Default period

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟢 Date Selector without TabBar
        DateSelector(
          tabController: DefaultTabController.of(context),
          selectedPeriod: selectedPeriod,
          onPeriodChanged: (String newPeriod) {
            setState(() => selectedPeriod = newPeriod);
          },
          showTabs: false, // 🟢 Hide the Income/Expenses TabBar
        ),
      ],
    );
  }
}
