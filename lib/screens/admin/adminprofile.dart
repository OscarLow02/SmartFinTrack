import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/admin/usermanage/manageuserfunction.dart';
import 'package:smart_fintrack/services/auth_service.dart';
import 'package:smart_fintrack/widgets/custom_container.dart';

class AdminProfile extends StatefulWidget {

  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  String username = "Loading...";
  String email = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    Map<String, dynamic>? userInfo = await getCurrentUserInfo();
    if (userInfo != null) {
      setState (() {
        username = userInfo['username'];
        email = userInfo['email'];
      });
    }
  }

  Future<void> updateUsername(String newUsername) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          "username": newUsername,
        });

        setState(() {
          username = newUsername;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Username updated successfully",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to update username",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showEditUsernameDialog() {
    TextEditingController usernameController = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text("New Username")),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(hintText: "Enter new username"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              String newUsername = usernameController.text.trim();
              if (newUsername.isNotEmpty) {
                updateUsername(newUsername);
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Text(
                        username[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProfileContainer(
                      label: "Username",
                      value: username,
                      isEditable: true,
                      onEdit: showEditUsernameDialog,
                    ),
                    const SizedBox(height: 16),
                    ProfileContainer(
                      label: "Email",
                      value: email,
                    ),
                    const SizedBox(height: 160),
                    ElevatedButton(
                      onPressed: () {
                        AuthService().signOut(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ), 
                      child: Text(
                        "Log Out",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
