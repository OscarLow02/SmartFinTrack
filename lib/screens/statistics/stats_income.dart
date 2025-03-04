import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/statistics/stats_category_details.dart';

class StatsIncome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟢 Placeholder for Pie Chart
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(child: Text("Pie Chart (Income)")),
        ),

        // 🟢 Income Category List
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Dummy count
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Category ${index + 1}"),
                subtitle: Text("RM ${100 + (index * 50)}"),
                trailing: Text("${(index + 1) * 10}%"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StatsCategoryDetail()),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
