import 'package:flutter/material.dart';

class SettingsPrivacyPolicy extends StatelessWidget {
  const SettingsPrivacyPolicy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const dummyPolicy = """
SmartFinTrack Privacy Policy

Effective Date: January 1, 2025

1. Introduction
Welcome to SmartFinTrack. We value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our app.

2. Information We Collect
- **Personal Information:** When you register or use our services, we may collect personal details such as your name, email address, and other relevant information.
- **Usage Data:** We automatically collect data about your interaction with the app, including device information, log data, and browsing actions.

3. How We Use Your Information
- To provide and maintain our services.
- To notify you about changes to our services.
- To offer customer support.
- To monitor usage and improve our app.
- To send periodic emails regarding updates, news, or promotional offers (you can opt out at any time).

4. Data Security
We implement a variety of security measures to protect your personal information from unauthorized access. However, no method of transmission over the internet or electronic storage is 100% secure.

5. Third-Party Services
We may employ third-party companies and services to facilitate our service, such as analytics providers and advertising partners. These third parties have access to your data only to perform specific tasks on our behalf and are obligated not to disclose or use it for any other purpose.

6. Your Data Rights
You have the right to access, correct, or delete your personal information. If you have any questions about your data or wish to exercise your rights, please contact us at support@smartfintrack.com.

7. Changes to This Privacy Policy
We may update our Privacy Policy from time to time. Any changes will be posted on this page with an updated effective date.

8. Contact Us
If you have any questions or concerns regarding this Privacy Policy, please contact us at:
Email: support@smartfintrack.com

By using SmartFinTrack, you agree to the collection and use of your information in accordance with this Privacy Policy.
""";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
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
