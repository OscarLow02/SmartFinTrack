import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'note_add.dart';

class NoteEdit extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> noteData;

  const NoteEdit({super.key, required this.docId, required this.noteData});

  @override
  State<NoteEdit> createState() => _NoteEditState();
}

class _NoteEditState extends State<NoteEdit> {
  late TextEditingController _noteController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.noteData['note']);

    // Convert stored string dateTime to DateTime
    selectedDate = DateTime.parse(widget.noteData['dateTime']);
  }

  Future<void> updateNote() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(widget.docId) // Update the specific note
        .update({
      'note': _noteController.text,
      'dateTime': selectedDate.toIso8601String(), // ✅ Save the updated date
    });

    Navigator.pop(context); // Go back to the list after updating
  }

  Future<void> deleteNote() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(widget.docId)
        .delete(); // ✅ Delete the note from Firestore

    Navigator.pop(context); // Go back to the list after deleting
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel deletion
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              deleteNote(); // Delete note from Firestore
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
        title: const Text(
          "Edit Note",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // ✅ Delete Button in AppBar
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: confirmDelete, // Show confirmation before deleting
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Keep Date Picker First (Same as NoteAdd)
            DatePickerExample(
              initialDate: selectedDate,
              onDateSelected: (newDate) {
                setState(() {
                  selectedDate = newDate;
                });
              },
            ),

            const SizedBox(height: 10),

            // ✅ TextField (Now below DatePicker)
            TextField(
              controller: _noteController,
              maxLines: null,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Note',
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Save Button (Consistent placement)
            ElevatedButton(
              onPressed: updateNote,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
