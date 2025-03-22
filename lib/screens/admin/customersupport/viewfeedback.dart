import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_fintrack/screens/admin/customersupport/handlesupport.dart';

class CustomerFeedbackTab extends StatelessWidget {
  const CustomerFeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("feedback").orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return const Center(child: Text("No feedback found."));
          }

          var feedbacksDoc = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbacksDoc.length,
            itemBuilder: (context, index) {
              var feedback = feedbacksDoc[index];
              String suggestion = feedback['feedback'] ?? 'No feedback';
              Timestamp? timestamp = feedback['timestamp'];

              // Format the timestamp
              String formattedDate = timestamp != null 
                  ? DateFormat('yyyy-MM-dd').format(timestamp.toDate()) 
                  : 'Unknown date';

              // Generate a random anonymous username
              String anonymousUser = 'User@${feedback.id.substring(0, 5)}';

              return GestureDetector(
                onTap: () => assignTicketDialog(context, feedback.id, suggestion),

                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User icon & username in a row
                        Row(
                          children: [
                            const Icon(Icons.account_circle, size: 40),
                            const SizedBox(width: 10),
                            Text(
                              anonymousUser,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18), 
                        // Feedback content
                        Text(
                          suggestion,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        // Submission date
                        Text(
                          'Submitted on: $formattedDate',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ), 
    );    
  }
}