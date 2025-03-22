import 'package:smart_fintrack/main.dart';
import 'package:smart_fintrack/screens/admin/bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/admin/systemmonitor/monitorfunction.dart';
import 'package:smart_fintrack/screens/user/auth_selection.dart';


class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // sign up function
  Future<String?> signUp(String username, String email, String password) async {
    try {
      UserCredential userCredent = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredent.user!.uid;

      //Store additional user data in Firestore
      await firestore.collection("users").doc(uid).set({
        "userID": uid,
        "username": username,
        "email": email,
        "role": "user",
        "status": "Active",
        "created_at": FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An error occurred. Please try again later.";
    }
  }

  // sign in function
  Future<void> signIn(BuildContext context, email, String password) async {
    try {
      UserCredential userCredent = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // retrieve user role
      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(userCredent.user!.uid).get();

      if (userDoc.exists) {
        String role = userDoc.get('role');
        String status = userDoc.get('status');

        if (role == 'user' && status == 'Active') {
          await recordAuthLog(userCredent.user!.uid, "Successful Login");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (role == 'admin' && status == 'Active') {
          await recordAuthLog(userCredent.user!.uid, "Successful Login");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminBottomBar()),
          );
        } else if (status == 'Suspended') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  "This account is suspended. Please contact support.",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                "This email account is deactivated. Please contact support.",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage =
          "Incorrect email or password! Please try again later.";

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              errorMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );

      QuerySnapshot userSnapShot = await firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .get();
      if (userSnapShot.docs.isNotEmpty) {
        await recordAuthLog(userSnapShot.docs[0].id, "Failed Login");
      }
    }
  }

  // get user info
  Stream<List<Map<String, dynamic>>> getUsersInfo() {
    return firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // sign out function
  Future<void> signOut(BuildContext context) async {
    try{
      User? user = auth.currentUser;

      if (user != null) {
        await recordAuthLog(user.uid, "Logout");
      }

      await auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthSelection()),
        (route) => false,  // Remove all routes from stack
      );
    }catch (e, stackTrace) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Error signing out. Please try again later.",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );

      await logErrorToFirestore(e, stackTrace);
    }
  }

  // record user activity log
  Future<void> recordAuthLog(String userID, String action) async {
    try{
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .collection('logs')
          .add({
        "action": action,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }catch(e, stackTrace) {
      print("Error recording log: $e");
      await logErrorToFirestore(e, stackTrace);
    }
  }
}
