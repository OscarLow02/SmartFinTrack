import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/statistics/stats_main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 0 = Transactions, 1 = Stats

  final List<Widget> _pages = [
    TransactionsPage(),
    const StatsPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent unnecessary reload

    setState(() {
      _selectedIndex = index; // Change the displayed page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Trans.",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

// 🟢 Dummy Transactions Page (Replace with real implementation)
class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Transactions"), backgroundColor: Colors.cyan),
      body: const Center(child: Text("Transactions Page")),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Settings"), backgroundColor: Colors.cyan),
      body: const Center(child: Text("Settings Page")),
    );
  }
}
