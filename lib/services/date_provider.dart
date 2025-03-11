import 'package:flutter/material.dart';

class DateProvider extends ChangeNotifier {
  DateTime _selectedDate =
      DateTime.now(); // Default to current month/year on first launch
  String _selectedPeriod = "Monthly"; // Default period

  DateTime get selectedDate => _selectedDate;
  String get selectedPeriod => _selectedPeriod;

  // 🛠 Update selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners(); // Notify UI to update
  }

  // 🛠 Update selected period (Monthly/Yearly)
  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners(); // Notify UI to update
  }
}
