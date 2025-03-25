import 'package:flutter/material.dart';
import 'package:smart_fintrack/widgets/view_mode.dart';

class StatsTransactionlist extends StatefulWidget {
  final String categoryGroup;
  final String selectedDate;
  final String selectedPeriod;
  final Map<String, Map<String, dynamic>> allTransactions;

  const StatsTransactionlist({
    super.key,
    required this.categoryGroup,
    required this.selectedDate,
    required this.selectedPeriod,
    required this.allTransactions,
  });

  @override
  _StatsTransactionListState createState() => _StatsTransactionListState();
}

class _StatsTransactionListState extends State<StatsTransactionlist> {
  late String _selectedPeriod;
  late DateTime _selectedDate;
  late List<DayGroup> dayGroups;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.selectedPeriod; // ✅ Use widget value
    // ✅ Convert selectedDate to DateTime properly
    try {
      _selectedDate = _convertToDate(widget.selectedDate);
    } catch (e) {
      _selectedDate =
          DateTime(2000, 1, 1); // Fallback to a default date if error occurs
    }
    // Group the data immediately
    dayGroups = _groupTransactions(
      widget.allTransactions,
      widget.categoryGroup,
      _selectedDate,
      _selectedPeriod,
    );
  }

  /// 🛠 Convert "Jan 2025" or "2025" → DateTime (Default to 1st day of the month)
  DateTime _convertToDate(String input) {
    List<String> monthNames = [
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

    List<String> shortMonthNames = [
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

    List<String> parts = input.split(" ");
    if (parts.length == 2) {
      String monthStr = parts[0];
      String yearStr = parts[1];

      int month = shortMonthNames.contains(monthStr)
          ? shortMonthNames.indexOf(monthStr) + 1
          : monthNames.indexOf(monthStr) + 1; // Convert month name to number

      int year = int.tryParse(yearStr) ?? DateTime.now().year; // Convert year

      if (month > 0) {
        return DateTime(
            year, month, 1); // Use the first day of the selected month
      }
    } else if (parts.length == 1) {
      int year = int.tryParse(parts[0]) ?? DateTime.now().year;
      return DateTime(
          year, 1, 1); // If only year is provided, default to Jan 1st
    }

    throw FormatException("Invalid date format: $input");
  }

  /// 🟢 Update Date based on ViewMode selection
  void _updateDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      debugPrint("New selected date: $_selectedDate");
      dayGroups = _groupTransactions(
        widget.allTransactions,
        widget.categoryGroup,
        _selectedDate,
        _selectedPeriod,
      );
    });
  }

  List<DayGroup> _groupTransactions(
    Map<String, Map<String, dynamic>> transactions,
    String categoryGroup,
    DateTime selectedDate,
    String selectedPeriod,
  ) {
    // 1. Filter by period (Monthly or Yearly)
    bool Function(DateTime) dateFilter;
    if (selectedPeriod == "Monthly") {
      // Check if transaction is in the same month/year
      dateFilter = (DateTime txDate) => (txDate.year == selectedDate.year &&
          txDate.month == selectedDate.month);
    } else {
      // "Yearly": check only the same year
      dateFilter = (DateTime txDate) => (txDate.year == selectedDate.year);
    }

    // 2. Filter & collect valid transactions
    List<Map<String, dynamic>> filtered = [];
    transactions.forEach((key, tx) {
      // Convert 'dateTime' to DateTime object
      DateTime? txDate = _tryParseDate(tx['dateTime']);
      if (txDate != null &&
          dateFilter(txDate) &&
          tx['category'] == categoryGroup) {
        filtered.add({
          ...tx,
          "parsedDate": txDate, // Store parsed DateTime
        });
      }
    });

    // 3. Group by date (e.g. "2025-03-19")
    //    We'll build a map of dateString -> items
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    for (var tx in filtered) {
      DateTime date = tx["parsedDate"];
      String dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      groupedByDate[dateStr] = groupedByDate[dateStr] ?? [];
      groupedByDate[dateStr]!.add(tx);
    }

    // 4. Convert to a list of DayGroup
    List<DayGroup> dayGroups = [];
    groupedByDate.forEach((dateStr, txList) {
      // Parse the dateStr back into a DateTime
      DateTime date = DateTime.parse(dateStr);

      // Calculate total income & expense for that day
      double incomeTotal = 0.0;
      double expenseTotal = 0.0;

      for (var tx in txList) {
        double amount = (tx["amount"] ?? 0.0).toDouble();
        if (tx["type"] == "Income") {
          incomeTotal += amount;
        } else {
          expenseTotal += amount;
        }
      }

      // Build items
      List<DayItem> items = txList.map((tx) {
        return DayItem(
          note: tx["note"] ?? "",
          account: tx["account"] ?? "",
          type: tx["type"] ?? "Expense",
          amount: (tx["amount"] ?? 0.0).toDouble(),
        );
      }).toList();

      dayGroups.add(DayGroup(
        date: date,
        incomeTotal: incomeTotal,
        expenseTotal: expenseTotal,
        items: items,
      ));
    });

    // 5. Sort dayGroups descending by date if you want newest on top
    dayGroups.sort((a, b) => b.date.compareTo(a.date));
    debugPrint(
        "Found ${filtered.length} transactions for date: $selectedDate and category: $categoryGroup");

    return dayGroups;
  }

// Attempt to parse "2025-03-19" or "2025-03-19 00:00" into DateTime
  DateTime? _tryParseDate(String dateTimeStr) {
    try {
      return DateTime.parse(dateTimeStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.categoryGroup,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ViewMode(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (newValue) {
              setState(() {
                _selectedPeriod = newValue;
                dayGroups = _groupTransactions(
                  widget.allTransactions,
                  widget.categoryGroup,
                  _selectedDate,
                  _selectedPeriod,
                );
              });
            },
            onDateChanged: _updateDate,
            initialDate: _selectedDate,
            transactions: widget.allTransactions,
            showTabs: false,
            showPeriodDropdown: false,
          ),
          // 🟢 Transaction List
          Expanded(
            child: ListView.builder(
              itemCount: dayGroups.length,
              itemBuilder: (context, index) {
                final group = dayGroups[index];
                return _buildDayTile(group);
              },
            ),
          )
        ],
      ),
    );
  }

  // Build each day's tile
  Widget _buildDayTile(DayGroup group) {
    final int weekday = group.date.weekday; // 1=Mon, 7=Sun
    final String dayName = _getDayOfWeek(weekday);
    final int dayOfMonth = group.date.day;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getDayColor(weekday),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "$dayOfMonth",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "RM ${group.incomeTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "RM ${group.expenseTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(color: Colors.grey, thickness: 0.5),
              Column(
                children: group.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          // Category Group
                          child: Text(widget.categoryGroup,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                        ),

                        // Note + Account
                        Expanded(
                          flex: 5, // Wider column for text
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.note,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.account,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price
                        Text(
                          "RM ${item.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: item.type == "Income"
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Convert weekday int to string: 1=Mon, 7=Sun
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
      default:
        return "Sun";
    }
  }

  // 1. Helper function to determine color by weekday
  Color _getDayColor(int weekday) {
    switch (weekday) {
      case 6: // Saturday
        return Colors.blue;
      case 7: // Sunday
        return Colors.red;
      default:
        return Colors.grey; // Monday–Friday
    }
  }
}

class DayGroup {
  final DateTime date;
  final double incomeTotal;
  final double expenseTotal;
  final List<DayItem> items;

  DayGroup({
    required this.date,
    required this.incomeTotal,
    required this.expenseTotal,
    required this.items,
  });
}

class DayItem {
  final String note;
  final String account;
  final String type; // "Income" or "Expense"
  final double amount;

  DayItem({
    required this.note,
    required this.account,
    required this.type,
    required this.amount,
  });
}
