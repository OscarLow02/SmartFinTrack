import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/admin/systemmonitor/bugreport.dart';
import 'package:smart_fintrack/screens/admin/systemmonitor/realtimeperform.dart';

class SystemMonitor extends StatefulWidget {
  const SystemMonitor({super.key});

  @override
  State<SystemMonitor> createState() => _SystemMonitorState();
}

class _SystemMonitorState extends State<SystemMonitor> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('System Monitoring'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom:  const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.speed), text: 'Performance'),
              Tab(icon: Icon(Icons.error_outline), text: 'Bug Reports'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RealTimePerformanceTab(),
            BugReportsTab(),
          ],
        )
      ),
    );
  }
}
