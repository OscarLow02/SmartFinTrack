import 'package:flutter/material.dart';

class SystemMonitor extends StatelessWidget {
  const SystemMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('System Monitoring')),
      ),
      body: Center(
        child: Text('System Monitoring Screen'),
      ),
    );
  }
}