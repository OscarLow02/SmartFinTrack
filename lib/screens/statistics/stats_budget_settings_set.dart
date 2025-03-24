import 'package:flutter/material.dart';
import 'package:smart_fintrack/services/firestore_service.dart';

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
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.initialAmount.toStringAsFixed(2));
  }

  String _getFormattedTitle() {
    // If the title indicates the default budget, return it as is.
    if (widget.title == "Set Default Budget") {
      return widget.title;
    }
    // Otherwise, build the title using the clicked label.
    return "Set Budget for ${widget.title}";
  }

  Future<void> _saveBudget() async {
    double newBudget =
        double.tryParse(_controller.text) ?? widget.initialAmount;
    try {
      await _updateBudgetInFirebase(newBudget);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Budget saved"),
          duration: Duration(seconds: 1),
        ),
      );
      // Await the delay before popping
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context, newBudget);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save budget: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Updates the budget in Firestore.
  Future<void> _updateBudgetInFirebase(double amount) async {
    // If the user tapped on "Default Budget", then widget.title might be "Set Default Budget".
    // Otherwise, widget.title is a month label like "Apr 2025" or a year string.
    if (widget.title == "Set Default Budget") {
      // This means the user wants to set a default for all months of the current year
      DateTime date = DateTime.parse(widget.selectedDate);
      await _firestoreService.updateBudgetData(
        periodType: "Monthly",
        dateKey: date.year.toString(), // or just pass the year
        limitValue: amount,
        isDefaultBudget: true, // now we know it's a default
      );
    } else {
      // Single month
      await _firestoreService.updateBudgetData(
        periodType: "Monthly",
        dateKey: widget.title, // e.g. "Mar 2025"
        limitValue: amount,
        isDefaultBudget: false,
      );
    }
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
        centerTitle: true,
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
