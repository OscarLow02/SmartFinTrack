import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Add camera function

class TransactionInputWidget extends StatefulWidget {
  final String type;

  const TransactionInputWidget({super.key, this.type = "income"});

  @override
  _TransactionInputWidgetState createState() => _TransactionInputWidgetState();
}

class _TransactionInputWidgetState extends State<TransactionInputWidget> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  late String _selectedCategory;
  String _selectedAccount = 'Cash';

  // For transfer transaction
  String _selectedAccount2 = 'Cash';

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

  List<String> get _categories =>
      widget.type == "income" ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();

    if (widget.type == "income") {
      _selectedCategory =
          _incomeCategories[0]; // Default to first income category
    } else {
      _selectedCategory =
          _expenseCategories[0]; // Default to first expense category
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

  // Called when clicking on Save
// Submit Data
  void _submitData() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    try {
      String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // ✅ Get the current user's UID
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User not signed in')));
        return;
      }
      String userId = user.uid; // Get UID of logged-in user

      // ✅ Prepare transaction data
      Map<String, dynamic> transactionData = {
        'amount': amount,
        'note': _noteController.text,
        'dateTime': dateString,
        'type': widget.type,
      };

      if (widget.type == "transfer") {
        transactionData['from'] = _selectedAccount;
        transactionData['to'] = _selectedAccount2;
      } else if (_selectedCategory == "Other") {
        transactionData['category'] = _otherController.text;
      } else {
        transactionData['category'] = _selectedCategory;
      }

      // ✅ Save inside the user's document: "users/{uid}/transactions"
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add(transactionData);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Transaction added')));

      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _selectedCategory = _categories[0];
        _selectedAccount = 'Cash';
        _selectedAccount2 = 'Cash';
      });
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
          // Date Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date: ${_selectedDate.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 18)),
              Container(
                margin: const EdgeInsets.all(5),
                width: 150,
                height: 25,
                child: ElevatedButton(
                    onPressed: _pickDate, child: const Text('Pick Date')),
              )
            ],
          ),

          // Amount Input
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
          ),

          if (widget.type != "transfer") ...[
            // Category Dropdown
            DropdownButtonFormField(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              value: _selectedCategory,
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

            // If Others is chosen
            if (_selectedCategory == "Other") ...[
              TextField(
                controller: _otherController,
                decoration:
                    const InputDecoration(labelText: 'Enter Category Here...'),
              ),
            ]
          ] else ...[
            // From Dropdown
            DropdownButtonFormField(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              value: _selectedAccount,
              items: _accounts.map((account) {
                return DropdownMenuItem(value: account, child: Text(account));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccount = value as String;
                });
              },
              decoration: const InputDecoration(labelText: 'From'),
            ),

            // To Dropdown
            DropdownButtonFormField(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              value: _selectedAccount2,
              items: _accounts.map((account) {
                return DropdownMenuItem(value: account, child: Text(account));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccount2 = value as String;
                });
              },
              decoration: const InputDecoration(labelText: 'To'),
            ),
          ],

          // Note Input
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),

          const SizedBox(height: 20),

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

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final Color _selectedColor = const Color.fromARGB(255, 36, 89, 185);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Add Transaction",
            style: TextStyle(fontSize: 17),
          ),
          backgroundColor: _selectedColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context); // ✅ Allow back navigation
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              tabs: [
                Tab(text: "Income"),
                Tab(text: "Expense"),
                Tab(text: "Transfer"),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  IncomeScreen(),
                  ExpenseScreen(),
                  TransferScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TransactionInputWidget(type: "income"),
    );
  }
}

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TransactionInputWidget(
          type: "expense"), // ExpenseScreen now properly passes type
    );
  }
}

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TransactionInputWidget(
          type: "transfer"), // ExpenseScreen now properly passes type
    );
  }
}
