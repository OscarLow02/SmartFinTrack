import 'package:flutter/material.dart';

class StatsBudgetSettingsSet extends StatefulWidget {
  final String title;

  const StatsBudgetSettingsSet({super.key, required this.title});

  @override
  _StatsBudgetSettingsSetState createState() => _StatsBudgetSettingsSetState();
}

class _StatsBudgetSettingsSetState extends State<StatsBudgetSettingsSet> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Enter Budget Limit"),
          onChanged: (value) {
            // Format input with commas and decimals
          },
        ),
      ),
    );
  }
}
