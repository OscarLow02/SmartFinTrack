import 'package:flutter/material.dart';
import 'ViewMode.dart';

class StatsNote extends StatefulWidget {
  const StatsNote({
    super.key,
  });

  @override
  _StatsNoteState createState() => _StatsNoteState();
}

class _StatsNoteState extends State<StatsNote>
    with SingleTickerProviderStateMixin {
  late String _selectedPeriod;
  late TabController _tabController;
  late DateTime _selectedDate;
  String selectedPeriod = "Monthly"; // ✅ Default to Monthly

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // ✅ Start with the current date
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 🟢 Implement Note Addition Logic
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // 🟢 ViewMode for Date & Period Selection
          ViewMode(
            selectedPeriod: selectedPeriod,
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

          // 🟢 Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                Center(child: Text("No Income Notes Yet.")),
                Center(child: Text("No Expense Notes Yet.")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
