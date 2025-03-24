import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SharedGoalsScreen extends StatefulWidget {
  const SharedGoalsScreen({super.key});

  @override
  _SharedGoalsScreenState createState() => _SharedGoalsScreenState();
}

class _SharedGoalsScreenState extends State<SharedGoalsScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _contributionAmountController =
      TextEditingController();
  final TextEditingController _inviteEmailController = TextEditingController();

  User? _currentUser = FirebaseAuth.instance.currentUser;
  List<QueryDocumentSnapshot> _sharedGoals = [];
  List<QueryDocumentSnapshot> _invitations = [];

  @override
  void initState() {
    super.initState();
    _fetchSharedGoals();
    _fetchInvitations();
  }

  void _fetchSharedGoals() async {
    if (_currentUser == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('shared_goals')
        .where("members", arrayContains: _currentUser!.uid)
        .get();

    setState(() {
      _sharedGoals = snapshot.docs;

      // Sort uncompleted goals first then completed goals
      _sharedGoals.sort((a, b) {
        var goalA = a.data() as Map<String, dynamic>;
        var goalB = b.data() as Map<String, dynamic>;

        String statusA = goalA["status"] ?? "active";
        String statusB = goalB["status"] ?? "active";

        if (statusA == "completed" && statusB != "completed") {
          return 1;
        } else if (statusA != "completed" && statusB == "completed") {
          return -1;
        }
        return 0;
      });
    });
  }

  void _fetchInvitations() async {
    if (_currentUser == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('invitations')
        .get();

    setState(() {
      _invitations = snapshot.docs;
    });
  }

  Future<void> _createSharedGoal() async {
    if (_goalNameController.text.isEmpty ||
        _targetAmountController.text.isEmpty) {
      return;
    }

    DocumentReference goalRef =
        FirebaseFirestore.instance.collection('shared_goals').doc();

    await goalRef.set({
      "goalId": goalRef.id,
      "goalName": _goalNameController.text,
      "targetAmount": double.parse(_targetAmountController.text),
      "currentAmount": 0,
      "createdBy": _currentUser!.uid,
      "members": [_currentUser!.uid],
      "status": "active"
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('shared_goals')
        .doc(goalRef.id)
        .set({"goalId": goalRef.id});

    _fetchSharedGoals();
  }

  Future<void> _inviteUserToGoal(String goalId, String email) async {
    var usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where("email", isEqualTo: email)
        .get();

    if (usersSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User not found")));
      return;
    }

    String invitedUserId = usersSnapshot.docs.first.id;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(invitedUserId)
        .collection('invitations')
        .doc(goalId)
        .set({
      "goalId": goalId,
      "invitedBy": _currentUser!.email,
      "status": "pending",
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Invitation sent!")));
  }

  Future<void> _acceptInvitation(String goalId) async {
    if (_currentUser == null) return;

    DocumentReference goalRef =
        FirebaseFirestore.instance.collection('shared_goals').doc(goalId);
    await goalRef.update({
      "members": FieldValue.arrayUnion([_currentUser!.uid])
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('shared_goals')
        .doc(goalId)
        .set({"goalId": goalId});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('invitations')
        .doc(goalId)
        .delete();

    _fetchSharedGoals(); // Refresh UI
  }

  Future<void> _contributeToGoal(String goalId, double amount) async {
    if (_currentUser == null) return;

    DocumentReference goalRef =
        FirebaseFirestore.instance.collection('shared_goals').doc(goalId);
    DocumentSnapshot goalSnapshot = await goalRef.get();

    if (!goalSnapshot.exists) return;

    var goalData = goalSnapshot.data() as Map<String, dynamic>;
    double currentAmount = (goalData["currentAmount"] as num).toDouble();
    double targetAmount = (goalData["targetAmount"] as num).toDouble();
    String status = goalData["status"] ?? "active";

    // If the goal is already completed, prevent further contributions
    if (status == "completed") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("This goal has already been completed!"),
      ));
      return;
    }

    double newTotal = currentAmount + amount;

    // Add contribution record
    await goalRef.collection('contributions').add({
      "userId": _currentUser!.uid,
      "amount": amount,
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now())
    });

    // If the new total reaches or exceeds the target, mark as completed
    if (newTotal >= targetAmount) {
      await goalRef.update({
        "currentAmount": newTotal,
        "status": "completed",
      });
    } else {
      // Otherwise, just update the current amount
      await goalRef.update({"currentAmount": FieldValue.increment(amount)});
    }

    _fetchSharedGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _goalNameController,
              decoration: const InputDecoration(labelText: "Goal Name"),
            ),
            TextField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Target Amount"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createSharedGoal,
              child: const Text("Create Goal"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _sharedGoals.length,
                itemBuilder: (context, index) {
                  var goal = _sharedGoals[index].data() as Map<String, dynamic>;
                  bool isCompleted = goal["status"] == "completed";

                  return Card(
                    child: ListTile(
                      title: Text(goal["goalName"]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "RM ${goal["currentAmount"]} / RM ${goal["targetAmount"]}"),
                          LinearProgressIndicator(
                              value:
                                  (goal["currentAmount"] / goal["targetAmount"])
                                      .clamp(0, 1)),
                          if (isCompleted)
                            const Text("Goal Completed ✅",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Disable Invite Button if Goal is Completed
                          if (!isCompleted)
                            IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Invite User"),
                                    content: TextField(
                                      controller: _inviteEmailController,
                                      decoration: const InputDecoration(
                                          labelText: "Enter user email"),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _inviteUserToGoal(goal["goalId"],
                                              _inviteEmailController.text);
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Send Invite"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          // Disable Contribution Button if Goal is Completed
                          if (!isCompleted)
                            IconButton(
                              icon: const Icon(Icons.attach_money),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Contribute to Goal"),
                                    content: TextField(
                                      controller: _contributionAmountController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          labelText: "Enter amount"),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          double amount = double.tryParse(
                                                  _contributionAmountController
                                                      .text) ??
                                              0;
                                          if (amount > 0) {
                                            _contributeToGoal(
                                                goal["goalId"], amount);
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text("Contribute"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _invitations.isEmpty
                  ? const Center(child: Text("No invitations found"))
                  : ListView.builder(
                      itemCount: _invitations.length,
                      itemBuilder: (context, index) {
                        var invitation =
                            _invitations[index].data() as Map<String, dynamic>;

                        return Card(
                          child: ListTile(
                            title: Text(
                                "Invitation to Join: ${invitation["goalId"]}"),
                            subtitle:
                                Text("Invited by: ${invitation["invitedBy"]}"),
                            trailing: ElevatedButton(
                              onPressed: () {
                                _acceptInvitation(invitation["goalId"]);
                              },
                              child: const Text("Accept"),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
