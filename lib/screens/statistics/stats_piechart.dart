import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_fintrack/screens/statistics/stats_linegraph.dart';

class StatsPieChart extends StatelessWidget {
  final String title; // "Income" or "Expenses"
  final List<String> categories;
  final List<double> amounts;
  final List<int> percentages;
  final List<Color> segmentColors; // 🆕 New Parameter
  final String selectedDate; // 🆕 Selected Date
  final String selectedPeriod; // 🆕 Selected Period

  const StatsPieChart({
    super.key,
    required this.title,
    required this.categories,
    required this.amounts,
    required this.percentages,
    required this.segmentColors, // 🆕 Accept dynamic colors
    required this.selectedDate, // 🆕 Initialize in constructor
    required this.selectedPeriod, // 🆕 Initialize in constructor
  });

  @override
  Widget build(BuildContext context) {
    // Define a high-contrast color palette
    final List<Color> contrastColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
      Colors.pink
    ];

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          // 🟢 Pie Chart
          Container(
            height: 250,
            width: 250,
            child: (categories.isEmpty ||
                    amounts.isEmpty ||
                    percentages.isEmpty)
                ? Center(child: Text("No data available"))
                : PieChart(
                    PieChartData(
                      sections: List.generate(categories.length, (index) {
                        return PieChartSectionData(
                          value: percentages[index].toDouble(),
                          title: "${(percentages[index]).toStringAsFixed(1)}%",
                          color: contrastColors[index %
                              contrastColors
                                  .length], // Use high-contrast colors
                          radius: 80,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          badgeWidget: Container(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              // ignore: unnecessary_string_interpolations
                              "${categories[index].length > 10 ? categories[index].substring(0, 10) + "..." : categories[index]}",
                              style: TextStyle(
                                color: contrastColors[
                                    index % contrastColors.length],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          badgePositionPercentageOffset: 1.5,
                        );
                      }),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
          ),

          const SizedBox(height: 20), // Spacing

          // 🟢 Category List
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 5.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatsLineGraph(
                            categoryGroup:
                                categories[index], // Existing parameter
                            selectedDate:
                                selectedDate, // New: Pass selected date
                            selectedPeriod:
                                selectedPeriod, // New: Pass period type
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 🟢 Percentage Box (Colored)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: contrastColors[
                                  index], // Match Pie Chart Color
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              "${percentages[index]}%",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12), // Spacing

                          // 🟢 Category Name
                          Expanded(
                            child: Text(
                              categories[index],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                          // 🟢 Amount (Currency)
                          Text(
                            "RM ${amounts[index].toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
