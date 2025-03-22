import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/admin/customersupport/viewfeedback.dart';
import 'package:smart_fintrack/screens/admin/customersupport/sendnotification.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Support'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom:  const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.feedback), text: 'User Complaints'),
              Tab(icon: Icon(Icons.notification_important), text: 'Send Notification'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CustomerFeedbackTab(),
            NotificationTab(),
          ],
        )
      ),
    );
  }
}