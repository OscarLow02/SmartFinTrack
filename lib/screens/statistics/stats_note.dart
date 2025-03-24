import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_fintrack/services/date_provider.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';

class StatsNote extends StatefulWidget {
  final Map<String, Map<String, dynamic>> incomeTransactions;
  final Map<String, Map<String, dynamic>> expenseTransactions;

  const StatsNote({
    super.key,
    required this.incomeTransactions,
    required this.expenseTransactions,
  });

  @override
  _StatsNoteState createState() => _StatsNoteState();
}

class _StatsNoteState extends State<StatsNote>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 2 tabs: Income + Expense
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterTransactions(
    Map<String, Map<String, dynamic>> transactions,
    DateTime selectedDate,
    String selectedPeriod,
  ) {
    final List<Map<String, dynamic>> filtered = [];

    transactions.forEach((id, tx) {
      final rawDate = tx["dateTime"]; // e.g., "2025-03-22"

      // Skip if null
      if (rawDate == null) return;

      // Parse the string to a DateTime object
      // Format must be "yyyy-MM-dd" for DateTime.parse() to work reliably
      final DateTime txDate = DateTime.parse(rawDate);

      if (selectedPeriod == "Monthly") {
        // Same year and month
        if (txDate.year == selectedDate.year &&
            txDate.month == selectedDate.month) {
          filtered.add(tx);
        }
      } else {
        // "Yearly": just match the year
        if (txDate.year == selectedDate.year) {
          filtered.add(tx);
        }
      }
    });

    debugPrint("Filtered: $filtered");
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);

    // 🟢 Filter the income/expense maps into lists
    final filteredIncomeList = _filterTransactions(
      widget.incomeTransactions,
      dateProvider.selectedDate,
      dateProvider.selectedPeriod,
    );

    final filteredExpenseList = _filterTransactions(
      widget.expenseTransactions,
      dateProvider.selectedDate,
      dateProvider.selectedPeriod,
    );

    return Scaffold(
      body: Column(
        children: [
          // 🟢 ViewMode for Date & Period Selection
          ViewMode(
            selectedPeriod: dateProvider.selectedPeriod,
            onPeriodChanged: (newValue) {
              dateProvider.setSelectedPeriod(newValue);
            },
            onDateChanged: (newDate) {
              dateProvider.setSelectedDate(newDate);
            },
            initialDate: dateProvider.selectedDate,
            tabController: _tabController,
          ),

          // 🟢 Tab View: Income vs. Expense
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Income Notes
                StatsNoteTable(
                  isIncome: true,
                  // Convert the filtered map to a list if needed
                  transactions: filteredIncomeList,
                ),

                // Expense Notes
                StatsNoteTable(
                  isIncome: false,
                  transactions: filteredExpenseList,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🟢 Table for Notes with grouping & sorting
class StatsNoteTable extends StatefulWidget {
  final bool isIncome;
  // We pass a List of transactions now (already filtered).
  final List<Map<String, dynamic>> transactions;

  const StatsNoteTable({
    super.key,
    required this.isIncome,
    required this.transactions,
  });

  @override
  State<StatsNoteTable> createState() => _StatsNoteTableState();
}

class _StatsNoteTableState extends State<StatsNoteTable> {
  bool _isQtyAscending = true;
  late List<Map<String, dynamic>> _groupedData;

  @override
  void initState() {
    super.initState();
    _groupedData = _groupByNote(widget.transactions);
    _sortByQuantity();
  }

  @override
  void didUpdateWidget(covariant StatsNoteTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If transactions changed, regroup & resort
    if (oldWidget.transactions != widget.transactions) {
      _groupedData = _groupByNote(widget.transactions);
      _sortByQuantity();
    }
  }

  /// Group transactions by 'note', summing 'amount' and counting how many times each note appears
  List<Map<String, dynamic>> _groupByNote(List<Map<String, dynamic>> rawList) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var tx in rawList) {
      final note = tx['note'] ?? 'Unknown';
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;

      if (!grouped.containsKey(note)) {
        grouped[note] = {
          'note': note,
          'quantity': 0,
          'amount': 0.0,
        };
      }
      grouped[note]!['quantity'] += 1;
      grouped[note]!['amount'] += amount;
    }

    // Convert map to a list
    return grouped.values.toList();
  }

  void _sortByQuantity() {
    setState(() {
      _groupedData.sort((a, b) {
        final cmp = a['quantity'].compareTo(b['quantity']);
        return _isQtyAscending ? cmp : -cmp;
      });
    });
  }

  void _onQtyHeaderTap() {
    setState(() {
      _isQtyAscending = !_isQtyAscending;
    });
    _sortByQuantity();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟢 Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _headerCell("Note", flex: 6, leftAlign: true),
              _qtyHeaderCell(),
              _headerCell("Amount", flex: 3),
            ],
          ),
        ),

        // 🟢 Data Rows
        Expanded(
          child: _groupedData.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _groupedData.length,
                  itemBuilder: (context, index) {
                    final item = _groupedData[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          _dataCell(item["note"], flex: 6, leftAlign: true),
                          _dataCell(item["quantity"].toString(), flex: 1),
                          _dataCell(
                            "RM ${item["amount"].toStringAsFixed(2)}",
                            flex: 3,
                            color: widget.isIncome
                                ? Colors.green
                                : Colors.redAccent,
                            rightAlign: true,
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    widget.isIncome
                        ? "No Income Notes Yet."
                        : "No Expense Notes Yet.",
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _qtyHeaderCell() {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: _onQtyHeaderTap,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Color.fromARGB(255, 173, 171, 171),
                width: 0.5,
              ),
              bottom: BorderSide(
                color: Color.fromARGB(255, 173, 171, 171),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 5),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Qty", style: _headerStyle),
              Icon(
                _isQtyAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 15,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String text, {required int flex, bool leftAlign = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Color.fromARGB(255, 173, 171, 171),
              width: 0.5,
            ),
            bottom: BorderSide(
              color: Color.fromARGB(255, 173, 171, 171),
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.only(bottom: 5),
        alignment: Alignment.center,
        child: Text(text, style: _headerStyle),
      ),
    );
  }

  Widget _dataCell(String text,
      {required int flex,
      bool leftAlign = false,
      Color? color,
      bool rightAlign = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: leftAlign
            ? const EdgeInsets.only(left: 8)
            : rightAlign
                ? EdgeInsets.only(right: 15)
                : EdgeInsets.zero,
        child: Text(
          text,
          style: _rowStyle.copyWith(color: color),
          textAlign: leftAlign
              ? TextAlign.left
              : (rightAlign ? TextAlign.right : TextAlign.center),
        ),
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(fontSize: 14, color: Colors.grey);
const TextStyle _rowStyle = TextStyle(fontSize: 14, color: Colors.black);
