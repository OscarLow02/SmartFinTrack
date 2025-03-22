import 'package:smart_fintrack/screens/admin/adminprofile.dart';
import 'package:smart_fintrack/screens/admin/customersupport/support.dart';
import 'package:smart_fintrack/screens/admin/systemmonitor/systemmonitor.dart';
import 'package:smart_fintrack/screens/admin/usermanage/usermanage.dart';
import 'package:flutter/material.dart';

class AdminBottomBar extends StatefulWidget {
  const AdminBottomBar({super.key});

  @override
  State<AdminBottomBar> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminBottomBar> {
  int _selectedIndex = 0;

  // Screens for each tab
  final List<Widget> _screens = [
    UserManage(),
    SystemMonitor(),
    Support(),
    AdminProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 30,), 
            label: "Users"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security), 
            label: "Security"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent), 
            label: "Support"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: "Profile"
          ),
        ],
      ),
    );
  }
}
