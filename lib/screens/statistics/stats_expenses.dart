import 'package:flutter/material.dart';

class StatsExpenses extends StatelessWidget {
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
          child: Center(child: Text("Pie Chart (Expenses)")),
        ),

        // 🟢 Expenses Category List
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Dummy count
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Category ${index + 1}"),
                subtitle: Text("RM ${100 + (index * 50)}"),
                trailing: Text("${(index + 1) * 10}%"),
              );
            },
          ),
        ),
      ],
    );
  }
}
