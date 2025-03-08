import 'package:flutter/material.dart';
import 'add_transactions.dart';
import 'daily_transactions.dart';
import 'package:intl/intl.dart';
import 'transactions_calender.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final Color _selectedColor = const Color.fromARGB(255, 36, 89, 185);

  DateTime _selectedDate = DateTime.now();

  void _changeMonth(int delta) {
    setState(() {
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedMonth = DateFormat('MMM yyyy').format(_selectedDate);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Transactions"),
          centerTitle: true,
          backgroundColor: _selectedColor,
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                ),
                Text(formattedMonth), // Display current selected month
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.arrow_forward_ios_outlined),
                ),
              ],
            ),
            const TabBar(
              tabs: [
                Tab(text: "Daily"),
                Tab(text: "Calendar"),
                Tab(text: "Monthly"),
                Tab(text: "Desc."),
              ],
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DailyTransactions(selectedDate: _selectedDate),
                  TableBasicsExample(selectedDate: _selectedDate),
                  const Icon(Icons.directions_bike),
                  const Icon(Icons.directions_bike),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.cyan,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddScreen()),
            );
          },
        ),
      ),
    );
  }
}
