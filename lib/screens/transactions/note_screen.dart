import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/transactions/note_edit.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<QueryDocumentSnapshot> notes = []; // ✅ Store Firestore documents

  @override
  void initState() {
    super.initState();
    fetchNotes(); // Fetch notes when the screen initializes
  }

  Future<void> fetchNotes() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure the user is logged in

    String userId = user.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .orderBy('dateTime', descending: true) // Sort by latest
        .get();

    setState(() {
      notes = snapshot.docs; // ✅ Store the actual Firestore documents
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: notes.isEmpty
          ? const Center(
              child: Text(
                "No Notes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ) // ✅ Show "No Notes" instead of loading spinner
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                var note = notes[index].data()
                    as Map<String, dynamic>; // ✅ Extract note data
                String docId = notes[index].id; // ✅ Get Firestore document ID

                // Convert stored string date to DateTime
                DateTime date = DateTime.parse(note['dateTime']);
                String formattedDate = '${date.day}/${date.month}/${date.year}';

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NoteEdit(docId: docId, noteData: note),
                    ),
                  ),
                  child: Card(
                    shape: const BeveledRectangleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['note'] ?? 'No content',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: null,
                            softWrap: true,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            formattedDate, // ✅ Show only the date
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
