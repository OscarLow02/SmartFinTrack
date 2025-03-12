import 'package:flutter/material.dart';
import 'stats_budget_settings_set.dart';
import 'package:smart_fintrack/widgets/ViewMode.dart';

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
  late String _selectedPeriod;
  late DateTime _selectedDate;
  double _defaultBudget = 1500.00;
  late List<double> _budgetList;
  String selectedPeriod = "Monthly";

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.selectedPeriod; // ✅ Use widget value
    // ✅ Convert selectedDate to DateTime properly
    try {
      _selectedDate = _convertToDate(widget.selectedDate);
    } catch (e) {
      _selectedDate =
          DateTime(2000, 1, 1); // Fallback to a default date if error occurs
    }
    // ✅ Initialize the budget list with dummy values for now
    _initializeBudgetList();

    // 🟢 Future Firestore Fetching Placeholder (to replace _initializeBudgetList)
    // fetchBudgetData();
  }

  /// 🛠 Initializes the budget list with default values
  void _initializeBudgetList() {
    int length = _selectedPeriod == "Monthly" ? 12 : 11;
    _budgetList = List.filled(length, _defaultBudget);
  }

  /// 🛠 Convert "Jan 2025" or "2025" → DateTime
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

  /// 🟢 Update Date based on ViewMode selection
  void _updateDate(DateTime newDate) {
    setState(() => _selectedDate = newDate);
  }

  /// 🟢 Update Default Budget (applies to all months/years)
  void _updateDefaultBudget(double newBudget) {
    setState(() {
      _defaultBudget = newBudget;
      _budgetList = List.filled(_budgetList.length, newBudget);
    });
  }

  /// 🟢 Update Individual Budget Entry
  void _updateBudgetForIndex(int index, double newBudget) {
    setState(() => _budgetList[index] = newBudget);
  }

  /// 🟢 Future Firestore Integration (Replace _initializeBudgetList)
  /*
  Future<void> fetchBudgetData() async {
    var snapshot = await FirebaseFirestore.instance.collection('budgets').get();
    if (snapshot.docs.isNotEmpty) {
      _budgetList = snapshot.docs.map((doc) => doc.data()['amount'] as double).toList();
      setState(() {}); // Refresh UI after fetching data
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    final bool isMonthly = _selectedPeriod == "Monthly";
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
    final int currentYear = _selectedDate.year;
    final List<int> yearRange =
        List.generate(11, (index) => currentYear - 5 + index);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Budget Settings",
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🟢 ViewMode for Period & Date Selection
          ViewMode(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (newValue) {
              setState(() {
                _selectedPeriod = newValue;
                _selectedDate = DateTime.now();
              });
            },
            onDateChanged: _updateDate,
            initialDate: _selectedDate,
            showTabs: false,
            showPeriodDropdown: false,
          ),

          // 🟢 Default Budget List Tile
          ListTile(
            title: const Text(
              ("Default Budget"),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              "RM ${_defaultBudget.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
              if (newBudget != null) _updateDefaultBudget(newBudget);
            },
          ),
          const Divider(),

          // 🟢 Budget List (Monthly or Yearly)
          Expanded(
            child: ListView.builder(
              itemCount: isMonthly ? months.length : yearRange.length,
              itemBuilder: (context, index) {
                final String label =
                    isMonthly ? months[index] : yearRange[index].toString();
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
                      _updateBudgetForIndex(index, newBudget);
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
