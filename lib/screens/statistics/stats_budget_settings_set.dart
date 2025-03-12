import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatsBudgetSettingsSet extends StatefulWidget {
  final String title;
  final double initialAmount;
  final String selectedPeriod;
  final String selectedDate;

  const StatsBudgetSettingsSet({
    super.key,
    required this.title,
    required this.initialAmount,
    required this.selectedPeriod,
    required this.selectedDate,
  });

  @override
  _StatsBudgetSettingsSetState createState() => _StatsBudgetSettingsSetState();
}

class _StatsBudgetSettingsSetState extends State<StatsBudgetSettingsSet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialAmount.toStringAsFixed(2));
  }

  String _getFormattedTitle() {
    if (widget.selectedPeriod == "Monthly") {
      DateTime date = DateTime.parse(widget.selectedDate);
      return DateFormat('MMM yyyy').format(date); // e.g., "Apr 2025"
    } else if (widget.selectedPeriod == "Yearly") {
      DateTime date = DateTime.parse(widget.selectedDate);
      return DateFormat('yyyy').format(date); // e.g., "2025"
    }
    return "Invalid Period"; // Default return statement
  }

  /// 🛠 Handles budget saving and Firebase integration (placeholder)
  void _saveBudget() {
    double newBudget =
        double.tryParse(_controller.text) ?? widget.initialAmount;
    _updateBudgetInFirebase(newBudget);
    Navigator.pop(context, newBudget);
  }

  /// 🛠 Placeholder for Firebase database update
  void _updateBudgetInFirebase(double amount) {
    // TODO: Implement Firebase database update
    print("Budget updated: RM $amount");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getFormattedTitle(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2459B9),
        centerTitle: true, // Aligns title to the left for readability
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25),
              decoration: const InputDecoration(
                hintText: "Enter budget amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Save",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
