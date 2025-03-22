import 'package:flutter/material.dart';
import 'stats_stats.dart';
import 'stats_budget.dart';
import 'stats_note.dart';
import 'package:smart_fintrack/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:smart_fintrack/services/date_provider.dart';

class StatsMain extends StatefulWidget {
  const StatsMain({super.key});

  @override
  _StatsMainState createState() => _StatsMainState();
}

class _StatsMainState extends State<StatsMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, Map<String, dynamic>> incomeTransactions = {};
  Map<String, Map<String, dynamic>> expenseTransactions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData(); // Fetch Firestore data on init
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    String selectedPeriod = dateProvider.selectedPeriod;
    DateTime selectedDate = dateProvider.selectedDate;

    // Fetch transactions for income and expenses
    Map<String, Map<String, dynamic>> incomeData =
        await _firestoreService.getTransactionsForStatistics(
            selectedDate: selectedDate, period: selectedPeriod, type: "Income");
    Map<String, Map<String, dynamic>> expenseData =
        await _firestoreService.getTransactionsForStatistics(
            selectedDate: selectedDate,
            period: selectedPeriod,
            type: "Expense");

    // IMPORTANT: Call setState to update the UI with the new data.
    setState(() {
      incomeTransactions = incomeData;
      expenseTransactions = expenseData;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color.fromARGB(255, 36, 89, 185);
    const Color unselectedColor = Colors.black;

    return Scaffold(
      body: Column(
        children: [
          // Custom Header (Title)
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            color: selectedColor,
            child: const Center(
              child: Text(
                "STATISTICS",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // TabBar (Stats, Budget, Notes)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: kToolbarHeight - 8.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: selectedColor,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: unselectedColor,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(icon: Icon(Icons.line_axis), text: "Stats"),
                  Tab(icon: Icon(Icons.money), text: "Budget"),
                  Tab(icon: Icon(Icons.note), text: "Note"),
                ],
              ),
            ),
          ),

          // TabBarView Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                StatsTab(
                  incomeTransactions: incomeTransactions,
                  expenseTransactions: expenseTransactions,
                  onRefresh: _fetchData,
                ),
                const DefaultTabController(
                  length: 2,
                  child: StatsBudget(),
                ),
                const StatsNote(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
