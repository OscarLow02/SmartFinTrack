import 'package:flutter/material.dart';
import 'stats_piechart.dart';
import 'ViewMode.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({
    super.key,
  });

  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedPeriod;
  late DateTime _selectedDate;
  String selectedPeriod = "Monthly"; // ✅ Default to Monthly

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedPeriod = selectedPeriod;
    _selectedDate = DateTime.now(); // ✅ Start with the current date
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
        // 🟢 ViewMode for Date & Period Selection
        ViewMode(
          selectedPeriod: _selectedPeriod,
          onPeriodChanged: (newValue) {
            setState(() {
              _selectedPeriod = newValue;
              _selectedDate = DateTime.now(); // ✅ Reset dynamically
            });
          },
          onDateChanged: _updateDate,
          tabController: _tabController,
          showTabs: true,
        ),

        // 🟢 Tab View (Income & Expenses Pie Charts)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              StatsPieChart(
                title: "Income",
                categories: ["Salary", "Allowance"],
                amounts: [3090.85, 150.00],
                percentages: [95, 5],
                defaultColor: Colors.green,
                selectedDate: _formatDate(_selectedDate),
                selectedPeriod: _selectedPeriod,
              ),
              StatsPieChart(
                title: "Expenses",
                categories: ["Food", "Transport", "Entertainment"],
                amounts: [300.00, 150.50, 80.25],
                percentages: [50, 30, 20],
                defaultColor: Colors.red,
                selectedDate: _formatDate(_selectedDate),
                selectedPeriod: _selectedPeriod,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
