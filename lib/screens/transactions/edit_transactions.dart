import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditTransactions extends StatefulWidget {
  final String type;

  final QueryDocumentSnapshot currentTransaction;

  const EditTransactions(
      {super.key, this.type = "income", required this.currentTransaction});

  @override
  _EditTransactionsState createState() => _EditTransactionsState();
}

class _EditTransactionsState extends State<EditTransactions> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();

  late DateTime _selectedDate;

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

    _selectedDate = DateTime.parse(widget.currentTransaction["dateTime"]);
    _amountController.text = widget.currentTransaction["amount"].toString();

    if (widget.currentTransaction["type"] != 'transfer') {
      _selectedCategory = widget.currentTransaction["category"];
    } else {
      if (widget.type == "income") {
        _selectedCategory = _incomeCategories[0];
      } else {
        _selectedCategory = _expenseCategories[0];
      }

      _selectedAccount = widget.currentTransaction["from"];
      _selectedAccount2 = widget.currentTransaction["to"];
    }

    _noteController.text = widget.currentTransaction["note"];
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
      String userId = user.uid;

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

      // ✅ Update the existing transaction instead of adding a new one
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(widget.currentTransaction.id) // ✅ Update by transaction ID
          .update(transactionData);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Transaction updated')));

      Navigator.pop(context); // ✅ Close screen after updating
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating transaction: $e')));
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

class EditScreen extends StatefulWidget {
  final QueryDocumentSnapshot currentTransaction;

  const EditScreen({
    super.key,
    required this.currentTransaction,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final Color _selectedColor = const Color.fromARGB(255, 36, 89, 185);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Transaction",
            style: TextStyle(fontSize: 17),
          ),
          backgroundColor: _selectedColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TabBar(
              tabs: [
                Tab(text: "Income"),
                Tab(text: "Expense"),
                Tab(text: "Transfer"),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  IncomeScreen(transaction: widget.currentTransaction),
                  ExpenseScreen(transaction: widget.currentTransaction),
                  TransferScreen(transaction: widget.currentTransaction),
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
  final QueryDocumentSnapshot transaction;

  const IncomeScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return EditTransactions(
      type: "income",
      currentTransaction: transaction,
    );
  }
}

class ExpenseScreen extends StatelessWidget {
  final QueryDocumentSnapshot transaction;

  const ExpenseScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return EditTransactions(type: "income", currentTransaction: transaction);
  }
}

class TransferScreen extends StatelessWidget {
  final QueryDocumentSnapshot transaction;

  const TransferScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return EditTransactions(
      type: "transfer",
      currentTransaction: transaction,
    );
  }
}
