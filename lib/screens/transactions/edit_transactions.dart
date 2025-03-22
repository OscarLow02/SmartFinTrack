import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'camera.dart';

class EditScreen extends StatefulWidget {
  final QueryDocumentSnapshot currentTransaction;

  const EditScreen({super.key, required this.currentTransaction});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();

    // Determine the tab based on transaction type
    String transactionType = widget.currentTransaction["type"];
    if (transactionType == "Expense") {
      _selectedTabIndex = 1;
    } else if (transactionType == "Transfer") {
      _selectedTabIndex = 2;
    }

    // Initialize the TabController with the selected tab index
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: _selectedTabIndex);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
        title: const Text("Edit Transaction",
            style: TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTransaction,
          ),
        ],
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(text: "Income"),
            Tab(text: "Expense"),
            Tab(text: "Transfer"),
          ],
        ),
      ),
      body: EditTransactions(
        currentTransaction: widget.currentTransaction,
        selectedTabIndex: _selectedTabIndex, // Pass the latest tab index
      ),
    );
  }

  void _deleteTransaction() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Transaction"),
        content:
            const Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not signed in')));
          return;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(widget.currentTransaction.id)
            .delete();

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Transaction deleted')));

        // ✅ Trigger UI refresh before navigating back
        if (mounted) {
          Navigator.pop(context, true); // Pass `true` to indicate deletion
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting transaction: $e')));
      }
    }
  }
}

class EditTransactions extends StatefulWidget {
  final QueryDocumentSnapshot currentTransaction;
  final int selectedTabIndex;

  const EditTransactions(
      {super.key,
      required this.currentTransaction,
      required this.selectedTabIndex});

  @override
  _EditTransactionsState createState() => _EditTransactionsState();
}

class _EditTransactionsState extends State<EditTransactions> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _imagePath;

  late DateTime _selectedDate;
  late String _selectedCategory;
  String _selectedFrom = 'Cash';
  String _selectedTo = 'Cash';
  String _selectedAccount = 'Cash';

  final List<String> _incomeCategories = [
    'Allowance',
    'Salary',
    'Petty Cash',
    'Bonus',
    'Other'
  ];

  final List<String> _expenseCategories = [
    'Food',
    'Social Life',
    'Pets',
    'Transport',
    'Culture',
    'Household',
    'Apparel',
    'Beauty',
    'Health',
    'Education',
    'Gift',
    'Other'
  ];

  final List<String> _accounts = ['Cash', 'Account', 'Credit Card'];

  List<String> get _categories {
    if (widget.selectedTabIndex == 0) return _incomeCategories;
    if (widget.selectedTabIndex == 1) return _expenseCategories;
    return [];
  }

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.parse(widget.currentTransaction["dateTime"]);
    _amountController.text = widget.currentTransaction["amount"].toString();
    _noteController.text =
        widget.currentTransaction["note"]; // ✅ Load note field

    List<String> categoryList =
        widget.selectedTabIndex == 0 ? _incomeCategories : _expenseCategories;

    if (widget.currentTransaction["type"] != 'Transfer') {
      _selectedCategory = widget.currentTransaction["category"];
      _selectedAccount = widget.currentTransaction["account"];
    } else {
      _selectedFrom = widget.currentTransaction["from"];
      _selectedTo = widget.currentTransaction["to"];
      _selectedCategory = categoryList.isNotEmpty ? categoryList[0] : "";
    }
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitData() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    try {
      String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User not signed in')));
        return;
      }
      String userId = user.uid;

      // Ensure selectedCategory is always from the correct list before saving
      if (widget.selectedTabIndex == 0) {
        // Income
        if (!_incomeCategories.contains(_selectedCategory)) {
          _selectedCategory =
              _incomeCategories.isNotEmpty ? _incomeCategories[0] : "";
        }
      } else if (widget.selectedTabIndex == 1) {
        // Expense
        if (!_expenseCategories.contains(_selectedCategory)) {
          _selectedCategory =
              _expenseCategories.isNotEmpty ? _expenseCategories[0] : "";
        }
      }

      // Delete the existing transaction
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(widget.currentTransaction.id)
          .delete();

      // Create a new transaction using the currently selected tab details
      Map<String, dynamic> transactionData = {
        'amount': amount,
        'note': _noteController.text,
        'dateTime': dateString,
      };

      if (_imagePath != null) {
        transactionData['imagePath'] = _imagePath; // Save the image path
      }

      if (widget.selectedTabIndex == 2) {
        transactionData['type'] = "Transfer";
        transactionData['from'] = _selectedFrom;
        transactionData['to'] = _selectedTo;
      } else {
        transactionData['type'] =
            widget.selectedTabIndex == 0 ? "Income" : "Expense";
        transactionData['category'] = _selectedCategory;
        transactionData['account'] = _selectedAccount;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add(transactionData);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Transaction saved')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date: ${_selectedDate.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 18)),
              ElevatedButton(
                  onPressed: _pickDate, child: const Text('Pick Date')),
            ],
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          if (_categories.isNotEmpty) ...[
            DropdownButtonFormField(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              value: _categories.contains(_selectedCategory)
                  ? _selectedCategory
                  : _categories[0],
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value as String;
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            // Account Dropdown
            DropdownButtonFormField(
              padding: const EdgeInsets.only(bottom: 10),
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
          ] else ...[
            DropdownButtonFormField(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              value: _selectedFrom,
              items: _accounts.map((from) {
                return DropdownMenuItem(value: from, child: Text(from));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFrom = value as String;
                });
              },
              decoration: const InputDecoration(labelText: 'From'),
            ),
            // To Dropdown field
            DropdownButtonFormField(
              padding: const EdgeInsets.only(bottom: 10),
              value: _selectedTo,
              items: _accounts.map((to) {
                return DropdownMenuItem(value: to, child: Text(to));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTo = value as String;
                });
              },
              decoration: const InputDecoration(labelText: 'To'),
            ),
          ],

          Container(
            padding: const EdgeInsets.only(bottom: 15),
            child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                  labelText: 'Note'), // ✅ Restored note input
            ),
          ),

          // Camera Button
          IconButton(
            onPressed: () async {
              final imagePath = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TakePictureScreen()),
              );

              if (imagePath != null) {
                setState(() {
                  _imagePath = imagePath;
                });
              }
            },
            icon: const Icon(Icons.camera_alt),
          ),

          // Image Preview
          if (_imagePath != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.file(File(_imagePath!), height: 100),
            ),

          // Submit Button
          Container(
            margin: const EdgeInsets.only(top: 5),
            height: 40,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitData,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
