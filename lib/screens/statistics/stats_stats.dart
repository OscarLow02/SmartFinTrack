import 'package:flutter/material.dart';
import "stats_piechart.dart";
import 'ViewMode.dart'; // Import modularized DateSelector widget

class StatsTab extends StatefulWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const StatsTab({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟢 Modularized Date Selector
        DateSelector(
          selectedPeriod: widget.selectedPeriod,
          onPeriodChanged: widget.onPeriodChanged,
          tabController: _tabController,
        ),

        // 🟢 Income & Expenses Pie Chart
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              StatsPieChart(
                title: "Income",
                categories: ["Salary", "Allowance"],
                amounts: [3090.85, 150.00],
                percentages: [95, 5],
                defaultColor: Colors.green,
              ),
              StatsPieChart(
                title: "Expenses",
                categories: ["Food", "Transport", "Entertainment"],
                amounts: [300.00, 150.50, 80.25],
                percentages: [50, 30, 20],
                defaultColor: Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
