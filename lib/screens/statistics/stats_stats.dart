import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stats_piechart.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';
import 'package:smart_fintrack/services/date_provider.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

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

  /// 🟢 Format Date for Display
  String _formatDate(DateTime date, String period) {
    return period == "Monthly"
        ? "${ViewMode.getMonthName(date.month)} ${date.year}" // "June 2023"
        : "${date.year}"; // "2023"
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider =
        Provider.of<DateProvider>(context); // ✅ Access Global State

    return Column(
      children: [
        // 🟢 ViewMode for Date & Period Selection
        ViewMode(
          selectedPeriod: dateProvider.selectedPeriod,
          onPeriodChanged: (newValue) =>
              dateProvider.setSelectedPeriod(newValue),
          onDateChanged: (newDate) => dateProvider.setSelectedDate(newDate),
          initialDate: dateProvider.selectedDate,
          tabController: _tabController,
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
                selectedDate: _formatDate(
                    dateProvider.selectedDate, dateProvider.selectedPeriod),
                selectedPeriod: dateProvider.selectedPeriod,
              ),
              StatsPieChart(
                title: "Expenses",
                categories: ["Food", "Transport", "Entertainment"],
                amounts: [300.00, 150.50, 80.25],
                percentages: [50, 30, 20],
                defaultColor: Colors.red,
                selectedDate: _formatDate(
                    dateProvider.selectedDate, dateProvider.selectedPeriod),
                selectedPeriod: dateProvider.selectedPeriod,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
