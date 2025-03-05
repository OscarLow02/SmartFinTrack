import 'package:flutter/material.dart';

class DateSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final TabController tabController;
  final bool showTabs; // 🟢 New parameter to control tab visibility

  const DateSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.tabController,
    this.showTabs = true, // Default: Show tabs unless specified otherwise
  });

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color.fromARGB(255, 36, 89, 185);
    const Color unselectedColor = Colors.black;

    return Column(
      children: [
        // 🟢 Month/Year Selector with Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Arrow Button
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios),
              ),

              // 🟢 Date Display
              const Expanded(
                flex: 7,
                child: Center(
                  child: Text("Mar 2023", style: TextStyle(fontSize: 16)),
                ),
              ),

              // Right Arrow Button
              IconButton(
                onPressed: () {},
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
                      value: selectedPeriod,
                      onChanged: (String? newValue) {
                        onPeriodChanged(newValue!);
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

        // 🟢 TabBar (Only show if `showTabs` is true)
        if (showTabs)
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: "Income"),
              Tab(text: "Expenses"),
            ],
            labelColor: selectedColor,
            indicatorColor: selectedColor,
            unselectedLabelColor: unselectedColor,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
      ],
    );
  }
}
