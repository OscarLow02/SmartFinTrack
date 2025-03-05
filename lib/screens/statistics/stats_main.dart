import 'package:flutter/material.dart';
import 'stats_budget.dart';
import 'stats_note.dart';
import 'stats_stats.dart';
import 'Header.dart'; // Import the reusable header

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = "Monthly"; // Controls Monthly/Yearly Dropdown

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
    return DefaultTabController(
      length: 3, // Ensures TabController works for all pages
      child: Scaffold(
        body: Column(
          children: [
            // 🟢 Reusable Header with Tabs
            StatsHeader(tabController: _tabController),

            // 🟢 TabBarView Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Stats Tab
                  StatsTab(
                    selectedPeriod: selectedPeriod,
                    onPeriodChanged: (String period) {
                      setState(() => selectedPeriod = period);
                    },
                  ),

                  // Budget Page
                  StatsBudget(
                    selectedPeriod: selectedPeriod,
                    onPeriodChanged: (String period) {
                      setState(() => selectedPeriod = period);
                    },
                  ),

                  // Note Page
                  StatsNote(
                    selectedPeriod: selectedPeriod,
                    onPeriodChanged: (String period) {
                      setState(() => selectedPeriod = period);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
