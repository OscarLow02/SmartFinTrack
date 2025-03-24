// import 'package:flutter/material.dart';
// import 'package:smart_fintrack/screens/user/feedback.dart';

// class SettingsHelpNSupport extends StatelessWidget {
//   const SettingsHelpNSupport({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Potential support info: FAQ, contact info, etc.
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text("Help & Support"),
//         backgroundColor: const Color.fromARGB(255, 36, 89, 185),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           const ListTile(
//             leading: Icon(Icons.contact_mail),
//             title: Text("Contact Us"),
//             subtitle: Text("Email: support@smartfintrack.com"),
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.feedback),
//             title: const Text("Submit Feedback"),
//             subtitle: const Text("Encounter an issue? Let us know."),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const userFeedback(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
