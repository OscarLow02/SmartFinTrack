import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/transactions/note_add.dart';
import 'package:smart_fintrack/screens/transactions/note_screen.dart';
import 'add_transactions.dart';
import 'daily_transactions.dart';
import 'package:intl/intl.dart';
import 'transactions_calender.dart';
import 'monthly_transactions.dart';

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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // ✅ Change month normally, but change year when on Monthly tab
  void _changeDate(int delta) {
    setState(() {
      if (_tabController.index == 2) {
        // Change YEAR in Monthly tab
        _selectedDate = DateTime(_selectedDate.year + delta, 1, 1);
      } else {
        // Change MONTH in other tabs
        _selectedDate =
            DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
      }
    });
  }

  // ✅ Updates UI when switching tabs
  void _onTabChanged() {
    setState(() {}); // Forces rebuild to reflect year/month change
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = _tabController.index == 2
        ? DateFormat('yyyy')
            .format(_selectedDate) // Show only year in Monthly tab
        : DateFormat('MMM yyyy')
            .format(_selectedDate); // Show full date in others

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
                  onPressed: () => _changeDate(-1),
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                ),
                Text(formattedDate), // Display current selected month or year
                IconButton(
                  onPressed: () => _changeDate(1),
                  icon: const Icon(Icons.arrow_forward_ios_outlined),
                ),
              ],
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Daily"),
                Tab(text: "Calendar"),
                Tab(text: "Monthly"),
                Tab(text: "Desc."),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DailyTransactions(selectedDate: _selectedDate),
                  TableBasicsExample(selectedDate: _selectedDate),
                  MonthlyTransactions(
                      selectedYear: _selectedDate
                          .year), // ✅ Now passes year instead of month
                  NoteScreen(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.cyan,
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
