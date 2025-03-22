import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_transactions.dart';
import 'transaction_card.dart';

class DailyTransactions extends StatelessWidget {
  final DateTime selectedDate;

  const DailyTransactions({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("User not signed in"));
    }
    String userId = user.uid; // Get user's UID

    String startOfMonth = "${DateFormat('yyyy-MM').format(selectedDate)}-01";
    String endOfMonth = "${DateFormat('yyyy-MM').format(selectedDate)}-31";

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('dateTime', isGreaterThanOrEqualTo: startOfMonth)
          .where('dateTime', isLessThanOrEqualTo: endOfMonth)
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No transactions found"));
        }

        var transactions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            var transaction = transactions[index];

            String dateString = transaction['dateTime'] as String;

            // Extract weekday
            DateTime date = DateTime.parse(dateString);
            DateFormat('E').format(date);

            // Extract day
            dateString.split('-');

            if (transaction['type'] == 'Transfer') {
            } else {}

            return TransactionCard(
              transaction: transactions[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditScreen(currentTransaction: transaction),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
