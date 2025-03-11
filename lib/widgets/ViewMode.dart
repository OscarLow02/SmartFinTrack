import 'package:flutter/material.dart';

class ViewMode extends StatefulWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final Function(DateTime) onDateChanged;
  final TabController? tabController;
  final bool showTabs;
  final bool showPeriodDropdown;
  final DateTime initialDate;

  const ViewMode({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.onDateChanged,
    required this.initialDate,
    this.tabController,
    this.showTabs = true,
    this.showPeriodDropdown = true,
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
    selectedDate = widget.initialDate; // Use parent-provided date
  }

  /// 🟢 Change Date (Previous / Next)
  void changeDate(int offset) {
    setState(() {
      if (widget.selectedPeriod == "Monthly") {
        int newMonth = selectedDate.month + offset;
        selectedDate = DateTime(selectedDate.year, newMonth, 1);
      } else {
        selectedDate = DateTime(selectedDate.year + offset, 1, 1);
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

  /// 🟢 Show Custom Month Picker
  void _showMonthPicker(BuildContext context) {
    final DateTime now = DateTime.now();
    int pickerYear = selectedDate.year;
    int pickerMonth = selectedDate.month;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey[900], // Dark theme like in your image
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Column(
                children: [
                  // 🟢 Header: "Date" | "This Month" | Close Button
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900],
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Date",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              pickerYear = now.year;
                              pickerMonth = now.month;
                              selectedDate = DateTime(now.year, now.month, 1);
                            });
                            widget.onDateChanged(selectedDate);
                            Navigator.pop(context);
                          },
                          child: Text("This month",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // 🟢 Year Selector
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    color: Colors.grey[850],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: () => setState(() => pickerYear--),
                        ),
                        Text(
                          "$pickerYear",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: () => setState(() => pickerYear++),
                        ),
                      ],
                    ),
                  ),

                  // 🟢 Month Selection Grid
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 4 columns for months
                        childAspectRatio: 2,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final monthName = ViewMode.getMonthName(index + 1);
                        bool isSelected = (index + 1 == pickerMonth &&
                            pickerYear == now.year);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = DateTime(pickerYear, index + 1, 1);
                            });
                            widget.onDateChanged(selectedDate);
                            Navigator.pop(context);
                          },
                          child: Center(
                            child: Text(
                              monthName,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.red : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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
                child: Center(
                  child: widget.selectedPeriod == "Monthly"
                      ? TextButton(
                          onPressed: () => _showMonthPicker(context),
                          child: Text(
                            getFormattedDate(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Text(
                          getFormattedDate(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // Right Arrow - Next Month/Year
              IconButton(
                onPressed: () => changeDate(1),
                icon: const Icon(Icons.arrow_forward_ios),
              ),

              // 🟢 Period Dropdown (Monthly/Yearly)
              if (widget.showPeriodDropdown)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 3.0),
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
                              child: Text("Yearly",
                                  style: TextStyle(fontSize: 11))),
                        ],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.black),
                        dropdownColor: Colors.white,
                        alignment: Alignment.center,
                        selectedItemBuilder: (BuildContext context) {
                          return ["Monthly", "Yearly"].map((period) {
                            return Center(
                              child: Text(period == "Monthly" ? "M" : "Y",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black)),
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
            indicatorSize: TabBarIndicatorSize.tab,
          ),
      ],
    );
  }
}
