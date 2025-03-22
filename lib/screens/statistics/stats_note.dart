import 'package:flutter/material.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';
import 'package:provider/provider.dart';
import 'package:smart_fintrack/services/date_provider.dart';

class StatsNote extends StatefulWidget {
  const StatsNote({
    super.key,
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
