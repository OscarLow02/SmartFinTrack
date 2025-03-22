import 'dart:io';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';

class RealTimePerformanceTab extends StatefulWidget {

  const RealTimePerformanceTab({super.key});

  @override
  State<RealTimePerformanceTab> createState() => _RealTimePerformanceTabState();
}

class _RealTimePerformanceTabState extends State<RealTimePerformanceTab> {
  final FirebasePerformance performance = FirebasePerformance.instance;
  String appLoadTime = 'Fetching...';
  String memoryUsage = 'Fetching...';

  @override
  void initState() {
    super.initState();
    calLoadTime();
    calMemoryUsage();
  }

  // calculate app load time
  Future<void> calLoadTime() async {
    final trace = performance.newTrace('app_start_trace');
    final stopwatch = Stopwatch()..start(); // Start tracking time
    await trace.start();
    await trace.stop();
    stopwatch.stop(); // Stop tracking time

    setState(() {
      appLoadTime = '${stopwatch.elapsedMilliseconds} ms'; // Get duration in milliseconds
    });
  }

  // calculate memory usage
  Future<void> calMemoryUsage() async {
    final bytes = ProcessInfo.currentRss; // Get memory usage in bytes
    double mb = bytes / (1024 * 1024); // Convert bytes to MB
    setState(() {
      memoryUsage = '${mb.toStringAsFixed(2)} MB';
    });
  }

  // refresh performance data
  void refreshData() {
    calLoadTime();
    calMemoryUsage();
  } 

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [ 
        Padding(
          padding:  const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:  CrossAxisAlignment.start,
            children: [
              const Text(
                'Real-time Performance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.speed, color: Colors.black),
                  title: const Text('App Load Time'),
                  subtitle: Text(appLoadTime),
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'Memory Usage',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.memory, color: Colors.black),
                  title: const Text('App Memory Usage'),
                  subtitle: Text(memoryUsage),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: FloatingActionButton(
              onPressed: refreshData,
              backgroundColor: Colors.grey[150],
              child: const Icon(Icons.refresh),
            ),
          ),
        ),
      ],
    );
  }
}
