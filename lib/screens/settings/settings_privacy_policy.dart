import 'package:flutter/material.dart';

class SettingsPrivacyPolicy extends StatelessWidget {
  const SettingsPrivacyPolicy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy text. In a real app, load from a file or server
    const dummyPolicy = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Praesent fermentum euismod nunc, sit amet lacinia quam aliquam ac. 
Vestibulum eu suscipit ex, sed pellentesque quam.
""";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Privacy Policy",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          dummyPolicy,
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
