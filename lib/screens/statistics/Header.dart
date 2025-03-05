import 'package:flutter/material.dart';

class StatsHeader extends StatelessWidget {
  final TabController tabController;

  const StatsHeader({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color.fromARGB(255, 36, 89, 185);
    const Color unselectedColor = Colors.black;

    return Column(
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
              controller: tabController,
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
      ],
    );
  }
}
