import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/transactions/note_edit.dart';

class NoteScreen extends StatefulWidget {
  final DateTime selectedDate;

  const NoteScreen({super.key, required this.selectedDate});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("No Notes"));
    }

    // Extract year and month from selectedDate
    String yearMonthFilter =
        "${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}";

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('notes')
              .where('dateTime', isGreaterThanOrEqualTo: "$yearMonthFilter-01")
              .where('dateTime', isLessThanOrEqualTo: "$yearMonthFilter-31")
              .orderBy('dateTime', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No Notes for this month"));
            }

            var notes = snapshot.data!.docs;

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                var note = notes[index].data() as Map<String, dynamic>;
                String docId = notes[index].id;
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 7, top: 10),
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: 2,
                                shape: const BeveledRectangleBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note['note'] ?? 'No content',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: null,
                                        softWrap: true,
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ));
              },
            );
          },
        ),
      ),
    );
  }
}
