import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class dailyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No transactions found"));
        }

        // Convert Firebase data into a list
        var transactions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            var transaction = transactions[index];
            return ListTile(
              title: Text("RM ${transaction['amount']}"), // Display amount
              subtitle: Text(transaction['note'] ?? 'No note'), // Display note
              trailing:
                  Text(transaction['type']), // Display type (income/expense)
            );
          },
        );
      },
    );
  }
}
