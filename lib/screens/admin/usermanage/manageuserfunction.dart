import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// delete user data from firestore
Future<void> deleteUserData(String userId) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    print("User deleted successfully");
  }catch(e) {
    print("Error deleting user: $e");
  }
}


Future<void> blockUser(String userId) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      "status": "Suspended"
    });
    print("User blocked successfully");
  }catch(e) {
    print("Error blocking user: $e");
  }
}

Future<void> resetUserPassword(BuildContext context, String email) async {
  try{
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Password reset link sent to $email",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }catch(e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Error sending password reset email",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

