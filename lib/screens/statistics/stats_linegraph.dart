import 'package:flutter/material.dart';
import 'package:smart_fintrack/data/dummy_transactions.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';

class StatsLineGraph extends StatefulWidget {
  final String categoryGroup; // Change from List<String> to String
  final String selectedDate;
  final String selectedPeriod;

  const StatsLineGraph({
    super.key,
    required this.categoryGroup, // Now a single string
    required this.selectedDate,
    required this.selectedPeriod,
  });

  @override
  _StatsLineGraphState createState() => _StatsLineGraphState();
}

class _StatsLineGraphState extends State<StatsLineGraph> {
  late String _selectedPeriod;
  late DateTime _selectedDate;
  String selectedPeriod = "Monthly"; // ✅ Default to Monthly

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

    throw FormatException(
        "Invalid date format: $input"); // Handle invalid format
  }

  /// 🟢 Update Date based on ViewMode selection
  void _updateDate(DateTime newDate) {
    setState(() => _selectedDate = newDate);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> transactions = dummyTransactions;
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
          // 🟢 Date Selector
          ViewMode(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (newValue) {
              setState(() {
                _selectedPeriod = newValue;
                _selectedDate = DateTime.now();
              });
            },
            onDateChanged: _updateDate,
            initialDate: _selectedDate,
            showTabs: false,
            showPeriodDropdown: false,
          ),

          // 🟢 Line Graph Placeholder
          Expanded(
            flex: 2, // Allocate space for line graph
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              color: Colors.grey[300], // Placeholder background
              child: const Center(child: Text("Line Graph Here")),
            ),
          ),

          // 🟢 Transaction List
          Expanded(
            flex: 3, // Allocate space for transaction list
            child: ListView.builder(
              itemCount:
                  transactions.length, // Use actual transaction list length
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
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
                          // 🟢 Upper Floor: Date & Total Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "${transaction['date']} (${transaction['day']})",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "RM ${transaction['totalAmount'].toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // 🔹 Grey Divider Line
                          const Divider(color: Colors.grey, thickness: 0.5),

                          // 🟢 Lower Floor: Category, Item, Account (Table-Like)
                          Column(
                            children:
                                List.generate(transaction['items'].length, (i) {
                              final item = transaction['items'][i];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Category Group (Only displayed on first row)
                                    i == 0
                                        ? Text(widget.categoryGroup,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey))
                                        : const SizedBox(
                                            width: 50), // Keep spacing

                                    // Item Name & Account
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        Text(item['account'],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),

                                    // Item Price
                                    Text(
                                        "RM ${item['price'].toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
