import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stats_piechart.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';
import 'package:smart_fintrack/services/date_provider.dart';
import 'package:smart_fintrack/services/statistics_service.dart';

class StatsTab extends StatefulWidget {
  final Map<String, Map<String, dynamic>> incomeTransactions;
  final Map<String, Map<String, dynamic>> expenseTransactions;
  final VoidCallback onRefresh;
  const StatsTab({
    super.key,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.onRefresh,
  });

  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, double> totalIncomeByCategory = {};
  Map<String, double> totalExpenseByCategory = {};
  Map<String, int> incomePercentages = {};
  Map<String, int> expensePercentages = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didUpdateWidget(covariant StatsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
        "StatsTab updated: incomeTransactions = ${widget.incomeTransactions}");
    debugPrint(
        "StatsTab updated: expenseTransactions = ${widget.expenseTransactions}");
  }

  /// Format Date for Display
  String _formatDate(DateTime date, String period) {
    return period == "Monthly"
        ? "${ViewMode.getMonthName(date.month)} ${date.year}"
        : "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);

    // Process the full transaction details to get totals and percentages.
    totalIncomeByCategory =
        StatisticsService.calculateCategoryTotals(widget.incomeTransactions);
    totalExpenseByCategory =
        StatisticsService.calculateCategoryTotals(widget.expenseTransactions);
    incomePercentages =
        StatisticsService.calculatePercentages(widget.incomeTransactions);
    expensePercentages =
        StatisticsService.calculatePercentages(widget.expenseTransactions);

    // Debugging output
    debugPrint("StatsTab - Income Transactions: ${widget.incomeTransactions}");
    debugPrint(
        "StatsTab - Expense Transactions: ${widget.expenseTransactions}");
    debugPrint("StatsTab - Total Income By Category: $totalIncomeByCategory");
    debugPrint("StatsTab - Total Expense By Category: $totalExpenseByCategory");
    debugPrint("StatsTab - Income Percentages: $incomePercentages");
    debugPrint("StatsTab - Expense Percentages: $expensePercentages");

    return Column(
      children: [
        // ViewMode for Date & Period Selection
        ViewMode(
          selectedPeriod: dateProvider.selectedPeriod,
          onPeriodChanged: (newValue) {
            dateProvider.setSelectedPeriod(newValue);
            widget.onRefresh(); // <-- Note the added parentheses
          },
          onDateChanged: (newDate) {
            dateProvider.setSelectedDate(newDate);
            widget.onRefresh(); // <-- Note the added parentheses
          },
          initialDate: dateProvider.selectedDate,
          tabController: _tabController,
        ),

        // Tab View (Income & Expenses Pie Charts)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              StatsPieChart(
                title: "Income",
                categories: totalIncomeByCategory.keys.toList(),
                amounts: totalIncomeByCategory.values.toList(),
                percentages: incomePercentages.values.toList(),
                segmentColors: List.generate(
                  totalIncomeByCategory.length,
                  (index) => Colors.primaries[index % Colors.primaries.length],
                ),
                selectedDate: _formatDate(
                    dateProvider.selectedDate, dateProvider.selectedPeriod),
                selectedPeriod: dateProvider.selectedPeriod,
              ),
              StatsPieChart(
                title: "Expenses",
                categories: totalExpenseByCategory.keys.toList(),
                amounts: totalExpenseByCategory.values.toList(),
                percentages: expensePercentages.values.toList(),
                segmentColors: List.generate(
                  totalExpenseByCategory.length,
                  (index) => Colors.primaries[index % Colors.primaries.length],
                ),
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
