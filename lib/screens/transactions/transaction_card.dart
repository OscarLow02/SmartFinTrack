import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final QueryDocumentSnapshot transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var data = transaction.data() as Map<String, dynamic>;

    // Extract and parse date
    dynamic dateValue = data['dateTime'];
    DateTime date;
    if (dateValue is Timestamp) {
      date = dateValue.toDate();
    } else if (dateValue is String) {
      date = DateTime.parse(dateValue);
    } else {
      date = DateTime.now();
    }

    String day = DateFormat('d').format(date);
    String weekday = DateFormat('E').format(date);

    Color typeColor = data['type'].toString().toLowerCase() == "income"
        ? Colors.green
        : data['type'].toString().toLowerCase() == "expense"
            ? Colors.red
            : Colors.black;

    IconData typeIcon = data['type'].toString().toLowerCase() == "income"
        ? Icons.arrow_upward
        : data['type'].toString().toLowerCase() == "expense"
            ? Icons.arrow_downward
            : Icons.compare_arrows;

    String transactionInfo;
    if (data['type'] == 'Transfer') {
      transactionInfo =
          "\n${data['from'] ?? 'Unknown'} → ${data['to'] ?? 'Unknown'}";
    } else {
      transactionInfo =
          "\n${data['category']}\n${data['account'] ?? 'No account'}";
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: typeColor.withOpacity(0.2),
              child: Icon(typeIcon, color: typeColor),
            ),
            title: Text(
              "RM${NumberFormat('#,##0.00').format(data['amount'])}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: typeColor,
              ),
            ),
            subtitle: Text(
              "${data['type']}$transactionInfo"
              "${data['note'].toString().trim().isNotEmpty ? '\n${data['note']}' : ''}",
              style: TextStyle(color: Colors.grey[700]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    weekday,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            onTap: onTap,
          ),

          // Display Image if Available
          if (data.containsKey('imagePath') && data['imagePath'] != null)
            Container(
              padding: EdgeInsets.all(5),
              child: Image.file(
                File(data['imagePath']),
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
