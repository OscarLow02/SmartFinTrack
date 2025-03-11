import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogPage extends StatelessWidget {
  final String userID;
  const ActivityLogPage(this.userID, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Log"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Authentication Activities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userID)
                    .collection('logs')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No activity logs found."));
                  }

                  var logs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      var log = logs[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(_getIconForActivity(log['action']), color: Colors.blue),
                          title: Text(log['action'] ?? "Unknown Activity"),
                          subtitle: Text(
                            _formatTimestamp(log['timestamp']),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForActivity(String? action) {
    switch (action) {
      case "Successful Login":
        return Icons.login;
      case "Logout":
        return Icons.logout;
      case "Failed Login Attempt":
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown time";

    DateTime date = timestamp.toDate().toLocal(); // Convert Timestamp to DateTime

    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
