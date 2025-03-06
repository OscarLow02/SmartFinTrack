import 'package:flutter/material.dart';

class CustomizeAppContent extends StatelessWidget {
  const CustomizeAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Customize App')),
      ),
      body: Center(
        child: Text('Customize App Feature'),
      ),
    );
  }
}