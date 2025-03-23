import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';
import 'stats_budget_settings.dart';
import 'package:smart_fintrack/services/date_provider.dart';
import 'package:smart_fintrack/services/firestore_service.dart';
import 'package:smart_fintrack/services/statistics_service.dart';

class StatsBudget extends StatefulWidget {
  final Map<String, Map<String, dynamic>> expenseTransactions;

  const StatsBudget({
    required this.expenseTransactions,
    super.key,
  });

  @override
  _StatsBudgetState createState() => _StatsBudgetState();
}

class _StatsBudgetState extends State<StatsBudget> {
  // Firestore service to fetch budget data
  final FirestoreService _firestoreService = FirestoreService();

  // Budget and Spent
  double budgetLimit = 0.0;
  double spentAmount = 0.0;
  double remainingAmount = 0.0;
  double progressPercentage = 0.0;

  // For category grouping
  Map<String, double> categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _calculateBudget();
  }

  // A convenient place to do async data fetch after the widget is mounted
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAndComputeBudget();
  }

  // 1) Fetch budget from Firestore
  // 2) Figure out the correct budget limit for the selected period/date
  // 3) Compute spentAmount from expenseTransactions
  // 4) Compute categoryTotals
  // 5) Rebuild UI with setState
  Future<void> _fetchAndComputeBudget() async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);

    // 1) Fetch budget data from Firestore
    // Make sure _firestoreService.userId is set somewhere in your app
    Map<String, Map<String, dynamic>> budgetData =
        await _firestoreService.fetchBudgetData();

    debugPrint("BUDGET DATA: $budgetData");

    // 2) Build the correct "key" for monthlyLimit or yearlyLimit
    String selectedPeriod =
        dateProvider.selectedPeriod; // "Monthly" or "Yearly"
    DateTime selectedDate = dateProvider.selectedDate;
    // For monthly: e.g. "Mar 2025"
    // For yearly: e.g. "2025"
    String dateKey = _formatDateKey(selectedDate, selectedPeriod);

    double newBudgetLimit = 0.0;
    if (selectedPeriod == "Monthly") {
      // If no entry, fallback to 0
      newBudgetLimit = (budgetData["monthlyLimit"]?[dateKey] ?? 0.0).toDouble();
    } else {
      // "Yearly"
      newBudgetLimit = (budgetData["yearlyLimit"]?[dateKey] ?? 0.0).toDouble();
    }

    // 3) Filter expenseTransactions based on the newly selected date.
    //    (Assuming the transaction’s "dateTime" field is in a parseable format.)
    List<Map<String, dynamic>> filteredTransactions = [];
    widget.expenseTransactions.forEach((key, tx) {
      DateTime? txDate = _tryParseDate(tx["dateTime"]);
      // For monthly, compare both year and month; for yearly, only the year.
      if (txDate != null) {
        bool matches = selectedPeriod == "Monthly"
            ? (txDate.year == selectedDate.year &&
                txDate.month == selectedDate.month)
            : (txDate.year == selectedDate.year);
        if (matches) {
          filteredTransactions.add(tx);
        }
      }
    });

    // 4) Compute the spent amount from the filtered transactions.
    double newSpentAmount = 0.0;
    for (var tx in filteredTransactions) {
      newSpentAmount += (tx["amount"] ?? 0.0).toDouble();
    }
    debugPrint("SPENT AMOUNT: $newSpentAmount");

    // 5) Compute category totals for display from the filtered transactions.
    // Convert the list to a Map<String, Map<String, dynamic>> using unique keys.
    Map<String, Map<String, dynamic>> transactionsMap = {
      for (int i = 0; i < filteredTransactions.length; i++)
        "tx$i": filteredTransactions[i]
    };
    Map<String, double> newCategoryTotals =
        StatisticsService.calculateCategoryTotals(transactionsMap);

    debugPrint("CATEGORY TOTALS: $newCategoryTotals");

    // 6) Compute remaining & progress
    double newRemaining = newBudgetLimit - newSpentAmount;
    double newProgress = (newBudgetLimit > 0)
        ? (newSpentAmount / newBudgetLimit).clamp(0.0, 1.0) * 100
        : 0;

    // 7) Update state
    setState(() {
      budgetLimit = newBudgetLimit;
      spentAmount = newSpentAmount;
      remainingAmount = newRemaining;
      progressPercentage = newProgress;
      categoryTotals = newCategoryTotals;
    });
  }

  // Helper: Convert date string to DateTime
  DateTime? _tryParseDate(String dateTimeStr) {
    try {
      return DateTime.parse(dateTimeStr);
    } catch (_) {
      return null;
    }
  }

  // Convert DateTime to "Mar 2025" or "2025"
  String _formatDateKey(DateTime date, String period) {
    if (period == "Monthly") {
      // Convert numeric month to name
      const monthNames = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ];
      String shortMonth = monthNames[date.month - 1].substring(0, 3);
      return "$shortMonth ${date.year}";
    } else {
      // "Yearly"
      return "${date.year}";
    }
  }

  void _calculateBudget() {
    setState(() {
      remainingAmount = budgetLimit - spentAmount;
      progressPercentage = budgetLimit > 0
          ? (spentAmount / budgetLimit).clamp(0.0, 1.0) * 100
          : 0;
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
    final dateProvider = Provider.of<DateProvider>(context);
    final categoryList = categoryTotals.entries.toList();
    const double barHeight = 20.0;
    // Determine if user exceeds the budget
    bool isOverBudget = progressPercentage > 100.0;

    // Decide the bar color (blue if remaining >= 0, red if negative)
    Color barColor =
        remainingAmount < 0 ? Colors.red : Color.fromARGB(255, 36, 89, 185);

    return Column(
      children: [
        // 🟢 ViewMode for Period & Date Selection
        ViewMode(
          selectedPeriod: dateProvider.selectedPeriod,
          onPeriodChanged: (newValue) {
            dateProvider.setSelectedPeriod(newValue);
            _fetchAndComputeBudget(); // Re-fetch & re-compute
          },
          onDateChanged: (newDate) {
            dateProvider.setSelectedDate(newDate);
            _fetchAndComputeBudget(); // Re-fetch & re-compute
          },
          initialDate: dateProvider.selectedDate,
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
                    // Left: Remaining Budget
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Remaining (${dateProvider.selectedPeriod})",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 81, 88, 101)),
                        ),
                        Text(
                          "RM ${remainingAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 30,
                            color:
                                remainingAmount < 0 ? Colors.red : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 36, 89, 185),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatsBudgetSettings(
                              selectedPeriod: dateProvider.selectedPeriod,
                              selectedDate: _formatDate(
                                  dateProvider.selectedDate,
                                  dateProvider.selectedPeriod),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Budget Setting >",
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
                            dateProvider.selectedPeriod,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 81, 88, 101)),
                          ),
                          Text(
                            "RM ${budgetLimit.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
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
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor:
                                    (progressPercentage / 100).clamp(0.0, 1.0),
                                child: Container(
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    color: barColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),

                              // 3) The percentage label on the right end
                              //    If progressPercentage > 100, text is white, else black
                              Positioned.fill(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 6.0),
                                      child: Text(
                                        "${progressPercentage.toStringAsFixed(0)}%",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isOverBudget
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                  "RM ${spentAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: barColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    "RM ${remainingAmount.toStringAsFixed(2)}"),
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: categoryList.length,
            itemBuilder: (context, index) {
              final entry = categoryList[index];
              return _buildCategoryTile(
                entry.key, // category
                entry.value, // amount
                index,
              );
            },
          ),
        ),
      ],
    );
  }

  final List<Color> _contrastColors = [
    const Color(0xFFBFD7EA), // Light Pastel Blue
    const Color(0xFFB39DDB), // Pastel Purple
    const Color(0xFFFF9AA2), // Pastel Pink
    const Color.fromARGB(255, 215, 138, 76), // Pastel Orange
    const Color(0xFFF9C74F), // Pastel Yellow
    const Color.fromARGB(255, 77, 175, 179), // Pastel Blue
    const Color.fromARGB(255, 154, 225, 199), // Pastel Mint
    const Color(0xFFDCE775), // Pastel Lime
    const Color(0xFFFFCCBC), // Pastel Peach
    const Color(0xFF80CBC4), // Pastel Teal
  ];

  Widget _buildCategoryTile(String category, double amount, int index) {
    // Pick a color from the list, cycling by index
    final Color color = _contrastColors[index % _contrastColors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12), // spacing

            // Category name
            Expanded(
              child: Text(
                category,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Amount (Currency)
            Text(
              "RM ${amount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
