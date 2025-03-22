import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/user/feedback.dart';

class CustomizeAppContent extends StatelessWidget {
  const CustomizeAppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Customize App')),
      ),
      body: TextButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => userFeedback()),
            );
          }, child: Text('Feedback'),
          
      ),
    );
  }
}