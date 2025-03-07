import 'package:flutter/material.dart';
import 'package:smart_fintrack/data/dummy_transactions.dart';

class StatsLineGraph extends StatelessWidget {
  final String categoryGroup; // Change from List<String> to String
  final String selectedDate;
  final String selectedPeriod;

  const StatsLineGraph({
    super.key,
    required this.categoryGroup, // Now a single string
    required this.selectedDate,
    required this.selectedPeriod,
  });
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> transactions = dummyTransactions;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          categoryGroup as String,
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
          // 🟢 Date Selector (Same as stats_stats.dart)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {},
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      selectedDate, // ✅ Now it dynamically updates!
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 🟢 Line Graph Placeholder
          Expanded(
            flex: 2, // Allocate space for line graph
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              color: Colors.grey[300], // Placeholder background
              child: const Center(child: Text("Line Graph Here")),
            ),
          ),

          // 🟢 Transaction List
          Expanded(
            flex: 3, // Allocate space for transaction list
            child: ListView.builder(
              itemCount:
                  transactions.length, // Use actual transaction list length
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🟢 Upper Floor: Date & Total Amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "${transaction['date']} (${transaction['day']})",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "RM ${transaction['totalAmount'].toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // 🔹 Grey Divider Line
                          const Divider(color: Colors.grey, thickness: 0.5),

                          // 🟢 Lower Floor: Category, Item, Account (Table-Like)
                          Column(
                            children:
                                List.generate(transaction['items'].length, (i) {
                              final item = transaction['items'][i];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Category Group (Only displayed on first row)
                                    i == 0
                                        ? Text(categoryGroup as String,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey))
                                        : const SizedBox(
                                            width: 50), // Keep spacing

                                    // Item Name & Account
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        Text(item['account'],
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),

                                    // Item Price
                                    Text(
                                        "RM ${item['price'].toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
