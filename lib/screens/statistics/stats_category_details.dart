import 'package:flutter/material.dart';

class StatsCategoryDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Category Details"), backgroundColor: Colors.cyan),
      body: Center(
        child: Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
          child: Center(child: Text("Line Graph Placeholder")),
        ),
      ),
    );
  }
}
