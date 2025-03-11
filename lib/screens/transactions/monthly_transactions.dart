import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonthlyTransactions extends StatefulWidget {
  final int selectedYear;

  const MonthlyTransactions({super.key, required this.selectedYear});

  @override
  State<MonthlyTransactions> createState() => _MonthlyTransactionsState();
}

class _MonthlyTransactionsState extends State<MonthlyTransactions> {
  final Map<String, Map<String, double>> monthlyTotals = {};
  final Map<String, List<Map<String, dynamic>>> transactions = {};
  String _expandedMonth = "";

  @override
  void initState() {
    super.initState();
    _listenForTransactions();
  }

  @override
  void didUpdateWidget(covariant MonthlyTransactions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear) {
      _listenForTransactions();
    }
  }

  void _listenForTransactions() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String userId = user.uid;
    String yearFilter = widget.selectedYear.toString();

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('dateTime', isGreaterThanOrEqualTo: "$yearFilter-01-01")
        .where('dateTime', isLessThanOrEqualTo: "$yearFilter-12-31")
        .snapshots() // ✅ Real-time listener
        .listen((snapshot) {
      Map<String, Map<String, double>> totals = {};
      Map<String, List<Map<String, dynamic>>> allTransactions = {};

      for (var doc in snapshot.docs) {
        String date = doc['dateTime'];
        String monthKey = date.substring(0, 7);
        double amount = (doc['amount'] as num).toDouble();
        String type = doc['type'] ?? "Other";
        String note = doc['note'] ?? "No note";

        if (!totals.containsKey(monthKey)) {
          totals[monthKey] = {"income": 0, "expense": 0};
        }

        if (type == "income") {
          totals[monthKey]!["income"] = totals[monthKey]!["income"]! + amount;
        } else if (type == "expense") {
          totals[monthKey]!["expense"] = totals[monthKey]!["expense"]! + amount;
        }

        if (!allTransactions.containsKey(monthKey)) {
          allTransactions[monthKey] = [];
        }
        allTransactions[monthKey]!.add({
          "amount": amount,
          "type": type,
          "date": date,
          "note": note,
        });
      }

      setState(() {
        monthlyTotals.clear();
        monthlyTotals.addAll(totals);
        transactions.clear();
        transactions.addAll(allTransactions);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: monthlyTotals.isEmpty
          ? const Center(child: Text("No transactions found"))
          : ListView.builder(
              itemCount: monthlyTotals.length,
              itemBuilder: (context, index) {
                String monthKey = monthlyTotals.keys.elementAt(index);
                DateTime monthDate = DateTime.parse("$monthKey-01");
                String monthName = DateFormat("MMMM").format(monthDate);
                bool isExpanded = _expandedMonth == monthKey;

                double income = monthlyTotals[monthKey]?["income"] ?? 0;
                double expense = monthlyTotals[monthKey]?["expense"] ?? 0;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedMonth = isExpanded ? "" : monthKey;
                        });
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  monthName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "+ RM${income.toStringAsFixed(2)}",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "- RM${expense.toStringAsFixed(2)}",
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isExpanded)
                      transactions[monthKey]?.isEmpty ?? true
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text("No transactions found"),
                            )
                          : Column(
                              children: transactions[monthKey]!
                                  .map(
                                    (transaction) => Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      child: ListTile(
                                        title: Text(
                                            "RM${transaction['amount']} - ${transaction['type']}"),
                                        subtitle: Text(
                                            "${transaction['date']} | ${transaction['note']}"),
                                        trailing: Icon(
                                          transaction['type'] == "income"
                                              ? Icons.trending_up
                                              : Icons.trending_down,
                                          color: transaction['type'] == "income"
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                  ],
                );
              },
            ),
    );
  }
}
