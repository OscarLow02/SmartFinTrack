import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'edit_transactions.dart';
import 'transaction_card.dart';

class FilterTransactionsScreen extends StatefulWidget {
  const FilterTransactionsScreen({super.key});

  @override
  _FilterTransactionsScreenState createState() =>
      _FilterTransactionsScreenState();
}

class _FilterTransactionsScreenState extends State<FilterTransactionsScreen> {
  String _selectedType = "All";
  String _selectedCategory = "All";
  String _selectedAccount = "All";

  DateTime? _startDate;
  DateTime? _endDate;

  List<QueryDocumentSnapshot> _filteredTransactions = [];

  final List<String> _transactionTypes = [
    "All",
    "Income",
    "Expense",
    "Transfer"
  ];
  final List<String> _incomeCategories = [
    "All",
    "Allowance",
    "Salary",
    "Bonus",
    "Petty Cash",
    "Other"
  ];
  final List<String> _expenseCategories = [
    "All",
    "Food",
    "Transport",
    "Shopping",
    "Health",
    "Other"
  ];
  final List<String> _accounts = ["All", "Cash", "Account", "Credit Card"];

  List<String> get _categories {
    if (_selectedType == "Income") return _incomeCategories;
    if (_selectedType == "Expense") return _expenseCategories;
    return ["All"];
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
  }

  // Date picker for selecting start or end date
  Future<void> _pickDate({required bool isStart}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _applyFilters() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions');

    // Apply transaction type filter
    if (_selectedType != "All") {
      query = query.where('type', isEqualTo: _selectedType);
    }

    // Apply account filter
    if (_selectedAccount != "All") {
      query = query.where('account', isEqualTo: _selectedAccount);
    }

    // Apply category filter (only for Income & Expense)
    if (_selectedType != "Transfer" && _selectedCategory != "All") {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    QuerySnapshot snapshot = await query.get();

    // Convert Firestore date strings to DateTime objects and filter by selected date range
    List<QueryDocumentSnapshot> filteredList = snapshot.docs.where((doc) {
      String dateString =
          (doc.data() as Map<String, dynamic>)['dateTime'] ?? "";
      DateTime? transactionDate = DateTime.tryParse(dateString);

      if (transactionDate == null) return false; // Skip invalid dates

      // Apply start date filter
      if (_startDate != null && transactionDate.isBefore(_startDate!)) {
        return false;
      }

      // Apply end date filter
      if (_endDate != null && transactionDate.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();

    setState(() {
      _filteredTransactions = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 36, 89, 185),
          title: const Text(
            "Filter Transactions",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start Date Picker
            ListTile(
              title: Text(_startDate == null
                  ? "Select Start Date"
                  : "Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: true),
            ),

            // End Date Picker
            ListTile(
              title: Text(_endDate == null
                  ? "Select End Date"
                  : "End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: false),
            ),

            const SizedBox(height: 10),

            // Transaction Type Dropdown
            DropdownButtonFormField(
              value: _selectedType,
              items: _transactionTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value as String;
                  _selectedCategory = _categories.first;
                });
              },
              decoration: const InputDecoration(labelText: 'Transaction Type'),
            ),

            const SizedBox(height: 10),

            // Account Dropdown
            DropdownButtonFormField(
              value: _selectedAccount,
              items: _accounts.map((account) {
                return DropdownMenuItem(value: account, child: Text(account));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccount = value as String;
                });
              },
              decoration: const InputDecoration(labelText: 'Account'),
            ),

            const SizedBox(height: 10),

            // Show Category dropdown only for Income & Expense
            if (_selectedType != "Transfer")
              DropdownButtonFormField(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                      value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value as String;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),

            const SizedBox(height: 20),

            // Apply Filters Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text("Apply Filters"),
              ),
            ),

            const SizedBox(height: 20),

            // Display filtered transactions
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? const Center(child: Text("No transactions found"))
                  : ListView.builder(
                      itemCount: _filteredTransactions.length,
                      itemBuilder: (context, index) {
                        var transaction = _filteredTransactions[index].data()
                            as Map<String, dynamic>;
                        (transaction['amount'] as num).toDouble();

                        return TransactionCard(
                          transaction: _filteredTransactions[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditScreen(
                                    currentTransaction:
                                        _filteredTransactions[index]),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
