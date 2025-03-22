import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/admin/bottom_bar.dart';
import 'package:smart_fintrack/screens/admin/usermanage/activitylog.dart';
import 'package:smart_fintrack/screens/admin/usermanage/manageuserfunction.dart';
import 'package:smart_fintrack/widgets/custom_card.dart';

class UserDetails extends StatelessWidget {
  final Map<String, dynamic> userData;
  const UserDetails({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminBottomBar()),
            );
          },
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (String choice) {
              if (choice == "ResetPassword") {
                resetUserPassword(context, userData["email"]);
              } else if (choice == "Delete") {
                showConfirmationDialog(context);
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: "ResetPassword",
                  child: Text("Reset Password"),
                ),
                const PopupMenuItem(
                  value: "Delete",
                  child: Text("Delete User"),
                ),
              ];
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userData["userID"])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userDoc = snapshot.data!.data();
          var updatedUserData = userDoc as Map<String, dynamic>;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 50,
                    child: Text(
                      updatedUserData["username"][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 3,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CardUserInfo(
                              icon: Icons.person,
                              text: updatedUserData["username"]),
                          CardUserInfo(
                              icon: Icons.email,
                              text: updatedUserData["email"]),
                          CardUserInfo(
                            icon: Icons.verified,
                            text: updatedUserData["status"],
                            statusColor: updatedUserData["status"] == "Active"
                                ? Colors.green
                                : Colors.red,
                            onTap: () => showBlockUnblockDialog(
                                context, updatedUserData),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OptionCard(
                      icon: Icons.history,
                      title: "Activity Log",
                      onTap: () {
                        // Navigate to activity log page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivityLogPage(userData["userID"]),
                          ),
                        );
                      }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete User"),
          content: Text("Are you sure you want to delete this user?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteUserData(userData["userID"]);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => AdminBottomBar()));
                SnackBar(
                    content: Center(
                      child: Text("User deleted successfully",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    backgroundColor: Colors.green);
              },
              child: const Text("Confirm", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Function to show a confirmation dialog for blocking/unblocking
  void showBlockUnblockDialog(
      BuildContext context, Map<String, dynamic> userData) {
    String currentStatus = userData["status"];
    String newStatus = currentStatus == "Active" ? "Suspended" : "Active";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$newStatus User"),
        content:
            Text("Are you sure you want to change the status to $newStatus?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              updateUserStatus(userData["userID"], newStatus);
            },
            child: Text(newStatus),
          ),
        ],
      ),
    );
  }

  /// Function to update status in Firebase
  void updateUserStatus(String userId, String newStatus) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'status': newStatus,
    }).then((_) {
      print("User status updated successfully");
    }).catchError((error) {
      print("Failed to update status: $error");
    });
  }
}
