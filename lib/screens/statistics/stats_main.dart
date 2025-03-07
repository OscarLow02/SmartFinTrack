import 'package:flutter/material.dart';
import 'stats_stats.dart';
import 'stats_budget.dart';
import 'stats_note.dart';

class StatsMain extends StatefulWidget {
  const StatsMain({super.key});

  @override
  _StatsMainState createState() => _StatsMainState();
}

class _StatsMainState extends State<StatsMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color.fromARGB(255, 36, 89, 185);
    const Color unselectedColor = Colors.black;

    return Scaffold(
      body: Column(
        children: [
          // 🟢 Custom Header (Title)
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

          // 🟢 TabBar (Stats, Budget, Notes)
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

          // 🟢 TabBarView Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Stats Tab
                StatsTab(),

                // Budget Page
                DefaultTabController(
                  length: 2, // Number of tabs you have
                  child: StatsBudget(),
                ),

                // Note Page
                StatsNote(), // Notes Page
              ],
            ),
          ),
        ],
      ),
    );
  }
}
