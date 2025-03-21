import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stats_piechart.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';
import 'package:smart_fintrack/services/date_provider.dart';
import 'package:smart_fintrack/services/firestore_service.dart';
import 'package:smart_fintrack/services/statistics_service.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, double> incomeData = {};
  Map<String, double> expenseData = {};
  Map<String, int> incomePercentages = {};
  Map<String, int> expensePercentages = {};
  // double totalIncome = 0.0; // Added totalIncome
  // double totalExpenses = 0.0; // Added totalExpenses

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData(); // Fetch Firestore Data
  }

  /// 🟢 Fetch Data from Firestore & Process Statistics
  Future<void> _fetchData() async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    String selectedPeriod = dateProvider.selectedPeriod;
    DateTime selectedDate = dateProvider.selectedDate;

    // Fetch transactions for income and expenses
    List<Map<String, dynamic>> incomeTransactions =
        await _firestoreService.getTransactionsForStatistics(
            selectedDate: selectedDate, period: selectedPeriod, type: "Income");

    List<Map<String, dynamic>> expenseTransactions =
        await _firestoreService.getTransactionsForStatistics(
            selectedDate: selectedDate,
            period: selectedPeriod,
            type: "Expense");

    // Process data
    setState(() {
      incomeData =
          StatisticsService.calculateCategoryTotals(incomeTransactions);
      expenseData =
          StatisticsService.calculateCategoryTotals(expenseTransactions);
      incomePercentages = StatisticsService.calculatePercentages(incomeData);
      expensePercentages = StatisticsService.calculatePercentages(expenseData);

      // totalIncome = incomeData.values.fold(0, (sum, amount) => sum + amount); // Compute total income
      // totalExpenses = expenseData.values.fold(0, (sum, amount) => sum + amount); // Compute total expenses
    });
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
          onPeriodChanged: (newValue) {
            dateProvider.setSelectedPeriod(newValue);
            _fetchData(); // Auto-refresh statistics when period changes
          },
          onDateChanged: (newDate) {
            dateProvider.setSelectedDate(newDate);
            _fetchData(); // Auto-refresh statistics when date changes
          },
          initialDate: dateProvider.selectedDate,
          tabController: _tabController,
          // totalIncome: totalIncome,
          // totalExpenses: totalExpenses,
        ),

        // 🟢 Tab View (Income & Expenses Pie Charts)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              StatsPieChart(
                title: "Income",
                categories: incomeData.keys.toList(),
                amounts: incomeData.values.toList(),
                percentages: incomePercentages.values.toList(),
                segmentColors: List.generate(
                    incomeData.length,
                    (index) => Colors.primaries[
                        index % Colors.primaries.length]), // Dynamic Colors
                selectedDate: _formatDate(
                    dateProvider.selectedDate, dateProvider.selectedPeriod),
                selectedPeriod: dateProvider.selectedPeriod,
              ),
              StatsPieChart(
                title: "Expenses",
                categories: expenseData.keys.toList(),
                amounts: expenseData.values.toList(),
                percentages: expensePercentages.values.toList(),
                segmentColors: List.generate(
                    expenseData.length,
                    (index) => Colors.primaries[
                        index % Colors.primaries.length]), // Dynamic Colors
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
