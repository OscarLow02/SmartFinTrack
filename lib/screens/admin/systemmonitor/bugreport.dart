import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/admin/systemmonitor/monitorfunction.dart';

class BugReportsTab extends StatefulWidget {
  const BugReportsTab({super.key});

  @override
  State<BugReportsTab> createState() => _BugReportsTabState();
}

class _BugReportsTabState extends State<BugReportsTab> {
  List<Map<String, dynamic>> crashReports = [];

  @override
  void initState() {
    super.initState();
    loadCrashReports();
  }

  Future<void> loadCrashReports() async {
    List<Map<String, dynamic>> reports = await fetchCrashReports();
    setState(() {
      crashReports = reports;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: crashReports.isEmpty
          ? const Center(child: Text('No crash reports found.'))
          : ListView.builder(
              itemCount: crashReports.length,
              itemBuilder: (context, index) {
                final report = crashReports[index];
                return Card(
                  elevation: 2,
                  child:  ListTile(
                    leading: const Icon(Icons.bug_report, color: Colors.red,),
                    title: Text(report['error'] ?? 'Unknown Error'),
                    subtitle: Text(report['timestamp']?.toDate().toString() ?? 'No timestamp'),
                  ),
                );
              },
            ),
    );
  }
}