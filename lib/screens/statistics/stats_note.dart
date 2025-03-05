import 'package:flutter/material.dart';
import 'ViewMode.dart';

class StatsNote extends StatefulWidget {
  const StatsNote(
      {super.key,
      required String selectedPeriod,
      required Null Function(String period) onPeriodChanged});

  @override
  _StatsNoteState createState() => _StatsNoteState();
}

class _StatsNoteState extends State<StatsNote> {
  String selectedPeriod = "Monthly"; // Default period

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟢 Date Selector
        DateSelector(
          tabController: DefaultTabController.of(context),
          selectedPeriod: selectedPeriod,
          onPeriodChanged: (String newPeriod) {
            setState(() => selectedPeriod = newPeriod);
          },
        ),
      ],
    );
  }
}
