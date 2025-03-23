import 'package:flutter/material.dart';
import 'stats_budget_settings_set.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';
import 'package:smart_fintrack/services/firestore_service.dart';

class StatsBudgetSettings extends StatefulWidget {
  final String selectedPeriod;
  final String selectedDate;

  const StatsBudgetSettings({
    super.key,
    required this.selectedPeriod,
    required this.selectedDate,
  });

  @override
  _StatsBudgetSettingsState createState() => _StatsBudgetSettingsState();
}

class _StatsBudgetSettingsState extends State<StatsBudgetSettings> {
  final FirestoreService _firestoreService = FirestoreService();

  late String _selectedPeriod;
  late DateTime _selectedDate;
  double _defaultBudget = 1500.00;
  late List<double> _budgetList;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.selectedPeriod; // Use widget value
    try {
      _selectedDate = _convertToDate(widget.selectedDate);
    } catch (e) {
      _selectedDate = DateTime(2000, 1, 1); // Fallback if error
    }
    _initializeBudgetList();

    // After init, fetch real data from Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshBudgetData();
    });
  }

  void _initializeBudgetList() {
    int length = _selectedPeriod == "Monthly" ? 12 : 11;
    _budgetList = List.filled(length, _defaultBudget);
  }

  DateTime _convertToDate(String input) {
    List<String> shortMonthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    List<String> parts = input.split(" ");
    if (parts.length == 2) {
      int month = shortMonthNames.indexOf(parts[0]) + 1;
      int year = int.tryParse(parts[1]) ?? DateTime.now().year;
      return DateTime(year, month, 1);
    } else if (parts.length == 1) {
      int year = int.tryParse(parts[0]) ?? DateTime.now().year;
      return DateTime(year, 1, 1);
    }
    throw FormatException("Invalid date format: $input");
  }

  Future<void> _refreshBudgetData() async {
    final budgetData = await _firestoreService.fetchBudgetData();

    if (_selectedPeriod == "Monthly") {
      int year = _selectedDate.year;
      final List<String> shortMonthNames = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];
      for (int i = 0; i < 12; i++) {
        String dateKey = "${shortMonthNames[i]} $year";
        double limit = (budgetData["monthlyLimit"]?[dateKey] ?? 0.0).toDouble();
        _budgetList[i] = limit;
      }
    } else {
      int centerYear = _selectedDate.year;
      List<int> yearRange = List.generate(11, (idx) => centerYear - 5 + idx);
      for (int i = 0; i < 11; i++) {
        String dateKey = yearRange[i].toString();
        double limit = (budgetData["yearlyLimit"]?[dateKey] ?? 0.0).toDouble();
        _budgetList[i] = limit;
      }
    }
    setState(() {});
  }

  // When the user changes the default budget, update local state.
  // The actual Firestore update will occur inside StatsBudgetSettingsSet.
  void _updateDefaultBudgetLocally(double newBudget) {
    setState(() {
      _defaultBudget = newBudget;
      for (int i = 0; i < _budgetList.length; i++) {
        _budgetList[i] = newBudget;
      }
    });
  }

  // When the user updates an individual entry, update local state.
  void _updateBudgetForIndexLocally(int index, double newBudget) {
    setState(() => _budgetList[index] = newBudget);
  }

  void _onDateChanged(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    _refreshBudgetData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMonthly = _selectedPeriod == "Monthly";
    int centerYear = _selectedDate.year;
    final List<int> yearRange =
        List.generate(11, (index) => centerYear - 5 + index);
    final List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Budget Settings",
          style: TextStyle(
              fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ViewMode for Period & Date Selection
          ViewMode(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (newValue) {
              setState(() {
                _selectedPeriod = newValue;
              });
              _initializeBudgetList();
              _refreshBudgetData();
            },
            onDateChanged: _onDateChanged,
            initialDate: _selectedDate,
            showTabs: false,
            showPeriodDropdown: false,
          ),
          // Default Budget List Tile
          ListTile(
            title: const Text(
              "Set Default Budget",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Apply to all budgets",
                style: const TextStyle(fontSize: 12)),
            trailing: Icon(Icons.ads_click),
            onTap: () async {
              final newBudget = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatsBudgetSettingsSet(
                    title: "Set Default Budget",
                    initialAmount: _defaultBudget,
                    selectedPeriod: _selectedPeriod,
                    selectedDate: _selectedDate.toString(),
                  ),
                ),
              );
              if (newBudget != null) {
                _updateDefaultBudgetLocally(newBudget);
              }
            },
          ),
          const Divider(
            thickness: 2.0,
          ),
          // Budget List (Monthly or Yearly)
          Expanded(
            child: ListView.builder(
              itemCount: isMonthly ? 12 : 11,
              itemBuilder: (context, index) {
                String label;
                if (isMonthly) {
                  label = "${months[index]} ${_selectedDate.year}";
                } else {
                  label = yearRange[index].toString();
                }
                return ListTile(
                  title: Text(label),
                  trailing: Text("RM ${_budgetList[index].toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 14)),
                  onTap: () async {
                    final newBudget = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatsBudgetSettingsSet(
                          title: label,
                          initialAmount: _budgetList[index],
                          selectedPeriod: _selectedPeriod,
                          selectedDate: _selectedDate.toString(),
                        ),
                      ),
                    );
                    if (newBudget != null) {
                      _updateBudgetForIndexLocally(index, newBudget);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
