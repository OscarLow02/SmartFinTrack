import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/transactions/note_add.dart';
import 'package:smart_fintrack/screens/transactions/note_screen.dart';
import 'package:smart_fintrack/screens/transactions/search_transactions.dart';
import 'add_transactions.dart';
import 'daily_transactions.dart';
import 'package:intl/intl.dart';
import 'transactions_calender.dart';
import 'monthly_transactions.dart';
import 'filter_transactions.dart';
import 'shared_goals.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  final Color _selectedColor = const Color.fromARGB(255, 36, 89, 185);
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _changeDate(int delta) {
    setState(() {
      if (_tabController.index == 2) {
        // Change year in Monthly tab
        _selectedDate = DateTime(_selectedDate.year + delta, 1, 1);
      } else {
        // Change month in other tabs
        _selectedDate =
            DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
      }
    });
  }

  // Updates UI when switching tabs
  void _onTabChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = _tabController.index == 2
        ? DateFormat('yyyy').format(_selectedDate)
        : DateFormat('MMM yyyy').format(_selectedDate);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Transactions",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: _selectedColor,
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchScreen()));
            },
            icon: const Icon(Icons.search),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list_alt, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FilterTransactionsScreen(),
                  ),
                );
              }, //
            ),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeDate(-1),
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                      color: const Color.fromARGB(215, 70, 47, 120),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ), // Display current selected month or year
                IconButton(
                  onPressed: () => _changeDate(1),
                  icon: const Icon(Icons.arrow_forward_ios_outlined),
                ),
              ],
            ),
            TabBar(
              controller: _tabController,
              labelPadding: EdgeInsets.all(1),
              labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Daily"),
                Tab(text: "Calendar"),
                Tab(text: "Monthly"),
                Tab(text: "Desc."),
                Tab(text: "Shared"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DailyTransactions(selectedDate: _selectedDate),
                  TableBasicsExample(selectedDate: _selectedDate),
                  MonthlyTransactions(selectedYear: _selectedDate.year),
                  NoteScreen(selectedDate: _selectedDate),
                  SharedGoalsScreen(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.white,
          backgroundColor: _selectedColor,
          child: const Icon(Icons.add),
          onPressed: () {
            if (_tabController.index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoteAdd()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddScreen()),
              );
            }
          },
        ),
      ),
    );
  }
}
