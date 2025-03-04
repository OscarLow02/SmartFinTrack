import 'package:flutter/material.dart';
import 'stats_income.dart';
import 'stats_expenses.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isIncomeSelected = true; // Controls Pie Chart (Income/Expenses)
  String selectedPeriod = "Monthly"; // Dropdown value
  final Color _selectedColor = const Color.fromARGB(255, 36, 89, 185);
  final Color _unselectedColor = Colors.black;

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
    return Scaffold(
      body: Column(
        children: [
          // 🟢 Custom Header (Replacing AppBar)
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            color: _selectedColor,
            child: const Center(
              child: Text(
                "STATISTICS",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),

          // 🟢 Custom TabBar with Solid Selected Background
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
                  borderRadius: BorderRadius.circular(8.0), // Rounded indicator
                  color: _selectedColor, // Background color of selected tab
                ),
                labelColor: Colors.white, // Selected tab text color
                unselectedLabelColor:
                    _unselectedColor, // Unselected tab text color
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(icon: Icon(Icons.line_axis), text: "Stats"),
                  Tab(icon: Icon(Icons.money), text: "Budget"),
                  Tab(icon: Icon(Icons.note), text: "Note"),
                ],
              ),
            ),
          ),

          // 🟢 Expanded TabBarView (To Avoid Overflow)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(), // Statistics Tab
                _buildPlaceholder("Budget Page"), // Budget Tab (Placeholder)
                _buildPlaceholder("Notes Page"), // Notes Tab (Placeholder)
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 Stats Tab Content
  Widget _buildStatsTab() {
    return Column(
      children: [
        // 🟢 Month/Year Selector with Dropdown
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_back_ios)),
              const Text("Mar 2023", style: TextStyle(fontSize: 16)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios)),
              DropdownButton<String>(
                value: selectedPeriod,
                items: ["Monthly", "Yearly"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedPeriod = value!);
                },
              ),
            ],
          ),
        ),

        // 🟢 Pie Chart Section Toggle (Income / Expenses)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _toggleButton("Income", true),
            _toggleButton("Expenses", false),
          ],
        ),

        // 🟢 Pie Chart Placeholder
        Expanded(
          child: isIncomeSelected ? StatsIncome() : StatsExpenses(),
        ),
      ],
    );
  }

  // 🟢 Helper Widget: Toggle Button for Income/Expenses
  Widget _toggleButton(String label, bool isIncome) {
    return TextButton(
      onPressed: () => setState(() => isIncomeSelected = isIncome),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isIncome == isIncomeSelected
              ? FontWeight.bold
              : FontWeight.normal,
          color:
              isIncome == isIncomeSelected ? _selectedColor : _unselectedColor,
        ),
      ),
    );
  }

  // 🟢 Placeholder for Budget & Notes Tabs
  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
