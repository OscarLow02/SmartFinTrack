import 'package:flutter/material.dart';

class ViewMode extends StatefulWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final Function(DateTime) onDateChanged;
  final TabController? tabController;
  final bool showTabs;

  const ViewMode({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.onDateChanged,
    this.tabController,
    this.showTabs = true,
  });

  @override
  State<ViewMode> createState() => _ViewModeState();

  /// 🟢 Convert month number to three-letter abbreviation
  static String getMonthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }
}

/// 🟢 Convert three-letter month abbreviation to month index
int getMonthIndex(String monthName) {
  const monthNames = [
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
  return monthNames.indexOf(monthName) + 1; // +1 to match month number
}

class _ViewModeState extends State<ViewMode> {
  late DateTime selectedDate;
  bool isCalendarOpen = false; // Calendar popup visibility

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Default to current month/year
  }

  /// 🟢 Change Date (Previous / Next)
  void changeDate(int offset) {
    setState(() {
      if (widget.selectedPeriod == "Monthly") {
        selectedDate = DateTime(selectedDate.year, selectedDate.month + offset);
      } else {
        selectedDate = DateTime(selectedDate.year + offset);
      }
    });

    widget.onDateChanged(selectedDate);
  }

  /// 🟢 Get Formatted Date for Display
  String getFormattedDate() {
    return widget.selectedPeriod == "Monthly"
        ? "${ViewMode.getMonthName(selectedDate.month)} ${selectedDate.year}" // "Jun 2023"
        : "${selectedDate.year}"; // "2023"
  }

  /// 🟢 Show Calendar Popup for Month Selection
  void openCalendarPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${selectedDate.year}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "This Month" Button
                TextButton(
                  onPressed: () {
                    setState(() => selectedDate = DateTime.now());
                    widget.onDateChanged(selectedDate);
                    Navigator.pop(context);
                  },
                  child:
                      const Text("This Month", style: TextStyle(fontSize: 14)),
                ),

                // List of 12 Months (Single Column for simplicity)
                SizedBox(
                  height: 300, // Set a height to avoid grid view issues
                  child: ListView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return TextButton(
                        onPressed: () {
                          setState(() {
                            selectedDate =
                                DateTime(selectedDate.year, index + 1);
                          });
                          widget.onDateChanged(selectedDate);
                          Navigator.pop(context);
                        },
                        child: Text(ViewMode.getMonthName(index + 1)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟢 Date Selector Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Arrow - Previous Month/Year
              IconButton(
                onPressed: () => changeDate(-1),
                icon: const Icon(Icons.arrow_back_ios),
              ),

              // Date Display (Clickable for Calendar in Monthly Mode)
              Expanded(
                flex: 7,
                child: Center(
                  child: widget.selectedPeriod == "Monthly"
                      ? TextButton(
                          onPressed: openCalendarPopup,
                          child: Text(getFormattedDate(),
                              style: const TextStyle(fontSize: 16)),
                        )
                      : Text(
                          getFormattedDate(),
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),

              // Right Arrow - Next Month/Year
              IconButton(
                onPressed: () => changeDate(1),
                icon: const Icon(Icons.arrow_forward_ios),
              ),

              // 🟢 Period Dropdown (Monthly/Yearly)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.selectedPeriod,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          widget.onPeriodChanged(newValue);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                            value: "Monthly",
                            child: Text("Monthly",
                                style: TextStyle(fontSize: 11))),
                        DropdownMenuItem(
                            value: "Yearly",
                            child:
                                Text("Yearly", style: TextStyle(fontSize: 11))),
                      ],
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      dropdownColor: Colors.white,
                      alignment: Alignment.center,
                      selectedItemBuilder: (BuildContext context) {
                        return ["Monthly", "Yearly"].map((period) {
                          return Center(
                            child: Text(period == "Monthly" ? "M" : "Y",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black)),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🟢 Show Tabs If Needed
        if (widget.showTabs && widget.tabController != null)
          TabBar(
            controller: widget.tabController,
            tabs: const [Tab(text: "Income"), Tab(text: "Expenses")],
          ),
      ],
    );
  }
}
