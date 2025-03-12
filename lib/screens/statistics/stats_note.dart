import 'package:flutter/material.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';
import 'package:provider/provider.dart';
import 'package:smart_fintrack/services/date_provider.dart';

class StatsNote extends StatefulWidget {
  const StatsNote({super.key});

  @override
  _StatsNoteState createState() => _StatsNoteState();
}

class _StatsNoteState extends State<StatsNote>
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
    final dateProvider =
        Provider.of<DateProvider>(context); // ✅ Access Global State

    return Scaffold(
      body: Column(
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

          // 🟢 Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                StatsNoteTable(isIncome: true), // ✅ Income Notes
                StatsNoteTable(isIncome: false), // ✅ Expense Notes
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🟢 Table for Notes (Dummy Data, Firestore Fetch in Future)
class StatsNoteTable extends StatelessWidget {
  final bool isIncome;

  const StatsNoteTable({super.key, required this.isIncome});

  @override
  Widget build(BuildContext context) {
    // ✅ Dummy Data (Firestore in Future)
    final List<Map<String, dynamic>> noteData = isIncome
        ? [
            {"note": "Freelance Work", "quantity": 2, "amount": 500.00},
            {"note": "Stock Dividend", "quantity": 1, "amount": 150.75},
          ]
        : [
            {"note": "Lunch", "quantity": 18, "amount": 168.80},
            {"note": "Breakfast", "quantity": 4, "amount": 31.50},
            {"note": "Dinner", "quantity": 4, "amount": 145.40},
            {"note": "大成碟碟", "quantity": 3, "amount": 55.30},
          ];

    return Column(
      children: [
        // Header Row with Column Borders
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _headerCell("Note", flex: 7, leftAlign: true),
              _headerCell("Qty", flex: 1),
              _headerCell("Amount", flex: 2),
            ],
          ),
        ),

        // Data Rows
        Expanded(
          child: noteData.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero, // ✅ Remove unwanted space
                  itemCount: noteData.length,
                  itemBuilder: (context, index) {
                    final item = noteData[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          _dataCell(item["note"], flex: 7, leftAlign: true),
                          _dataCell(item["quantity"].toString(), flex: 1),
                          _dataCell(
                            "RM ${item["amount"].toStringAsFixed(2)}",
                            flex: 2,
                            color: isIncome ? Colors.green : Colors.redAccent,
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    isIncome ? "No Income Notes Yet." : "No Expense Notes Yet.",
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
        ),
      ],
    );
  }

  // 🟢 Header Cell with Border
  Widget _headerCell(String text, {required int flex, bool leftAlign = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(
                color: Color.fromARGB(255, 173, 171, 171),
                width: 0.5), // ✅ Column Border
            bottom: BorderSide(
                color: Color.fromARGB(255, 173, 171, 171),
                width: 0.5), // ✅ Bottom Border
          ),
        ),
        padding: const EdgeInsets.only(bottom: 5),
        alignment: Alignment.center,
        child: Text(text, style: _headerStyle),
      ),
    );
  }

  // 🟢 Data Cell
  Widget _dataCell(String text,
      {required int flex, bool leftAlign = false, Color? color}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: leftAlign ? const EdgeInsets.only(left: 8) : EdgeInsets.zero,
        child: Text(
          text,
          style: _rowStyle.copyWith(color: color),
          textAlign: leftAlign ? TextAlign.left : TextAlign.center,
        ),
      ),
    );
  }
}

// 🟢 Styles
const TextStyle _headerStyle = TextStyle(fontSize: 14, color: Colors.grey);

const TextStyle _rowStyle = TextStyle(fontSize: 14, color: Colors.black);
