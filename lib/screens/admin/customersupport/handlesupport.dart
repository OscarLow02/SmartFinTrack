import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Show dialog to confirm assigning a ticket for feedback
void assignTicketDialog(BuildContext context, String feedbackId, String feedbackText) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text("Assign Feedback"),
        content: const Text("Are you sure you want to assign a ticket for this feedback to support teams?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              assignTicket(feedbackId);
              Navigator.pop(dialogContext); // Close dialog
            },
            child: const Text("Assign"),
          ),
        ],
      );
    },
  );
}

// Assign feedback as a ticket in Firestore
void assignTicket(String feedbackId) {
  FirebaseFirestore.instance.collection("support_tickets").add({
    'feedbackId': feedbackId,
    'status': "Unresolved",
    'assignedTo': "Support Team",
    'timestamp': FieldValue.serverTimestamp(),
  });
}
