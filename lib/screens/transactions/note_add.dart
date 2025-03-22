import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NoteAdd extends StatefulWidget {
  const NoteAdd({super.key});

  @override
  State<NoteAdd> createState() => _NoteAddState();
}

class _NoteAddState extends State<NoteAdd> {
  final TextEditingController _noteController = TextEditingController();
  DateTime selectedDate = DateTime.now(); // Ensure a default value

  Future<void> submitNote() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    String userId = user.uid;

    Map<String, dynamic> noteData = {
      'note': _noteController.text,
      'dateTime': selectedDate.toIso8601String(), // Store date in ISO format
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .add(noteData);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Note added')));

    _noteController.clear();
  }

  void updateSelectedDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DatePickerExample(
              initialDate: selectedDate,
              onDateSelected: updateSelectedDate,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: _noteController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: 'Note',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                onPressed: submitNote,
                child: const Text("Save"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DatePickerExample extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const DatePickerExample({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DatePickerExample> createState() => _DatePickerExampleState();
}

class _DatePickerExampleState extends State<DatePickerExample> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
      widget.onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _selectDate, // Ensure button works
      style: OutlinedButton.styleFrom(
        shape: const ContinuousRectangleBorder(),
      ),
      child: Text(
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
      ),
    );
  }
}
