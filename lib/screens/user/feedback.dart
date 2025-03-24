import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class userFeedback extends StatefulWidget {
  const userFeedback({super.key});

  @override
  State<userFeedback> createState() => _userFeedbackState();
}

class _userFeedbackState extends State<userFeedback> {
  final TextEditingController _feedbackController = TextEditingController();
  int charCount = 0;
  bool isLoading = false;

  void onTextChanged(String text) {
    setState(() {
      charCount = text.length;
    });
  }

  Future<void> submitFeedback() async {
    if (charCount <= 10) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection("feedback").add({
        'feedback': _feedbackController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Feedback submitted successfully!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ),
      );

      _feedbackController.clear();
      onTextChanged('');
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting feedback. Try again!")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your feedback is important to us! What can we improve on? *',
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400)),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _feedbackController,
                        onChanged: onTextChanged,
                        maxLines: 10,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your feedback here...',
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Text(
                          '$charCount/1000',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your responses are completely anonymous, and every answer you give will help make our platform stronger.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: charCount > 10 ? submitFeedback : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          charCount > 10 ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Submit'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
