import 'package:flutter/material.dart';
import 'package:smart_fintrack/services/auth_service.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // If using Firebase Auth
// import 'package:smart_fintrack/services/auth_service.dart';

class SettingsLoginSecurity extends StatefulWidget {
  final String userId;
  final String loginEmail;

  const SettingsLoginSecurity({
    Key? key,
    required this.userId,
    required this.loginEmail,
  }) : super(key: key);

  @override
  State<SettingsLoginSecurity> createState() => _SettingsLoginSecurityState();
}

class _SettingsLoginSecurityState extends State<SettingsLoginSecurity> {
  bool _isTwoStepEnabled = false;
  bool _showPasswordPrompt = false;
  bool _showSecurityPanel = false;

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Login & Security",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _showPasswordPrompt
              ? _buildPasswordPrompt()
              : _showSecurityPanel
                  ? _buildSecurityPanel()
                  : _buildMainList(),
        ),
      ),
    );
  }

  /// Main list: shows login email, password field, 2-step toggle, delete account
  Widget _buildMainList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password
        ListTile(
          title: const Text("Password"),
          subtitle: const Text("********"),
          trailing: const Icon(Icons.edit, color: Colors.grey),
          onTap: () {
            // Prompt for current password first
            setState(() {
              _showPasswordPrompt = true;
            });
          },
        ),
        const Divider(),

        // Two-step verification
        SwitchListTile(
          title: const Text("Two step verification"),
          value: _isTwoStepEnabled,
          onChanged: (value) {
            setState(() {
              _isTwoStepEnabled = value;
            });
            // TODO: Save to Firestore or Auth logic
            // e.g., AuthService().setTwoFactorEnabled(widget.userId, value);
          },
        ),
        const Divider(),

        // Delete My Account
        ListTile(
          title: const Text("Delete my account"),
          trailing: const Icon(Icons.delete, color: Colors.red),
          onTap: () {
            _confirmAccountDeletion();
          },
        ),
      ],
    );
  }

  /// Prompt user for current password
  Widget _buildPasswordPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter your current password",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _currentPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _showPasswordPrompt = false;
                });
              },
              child: const Text("Back"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 36, 89, 185),
              ),
              onPressed: () {
                // Validate the password
                _verifyCurrentPassword(_currentPasswordController.text.trim());
              },
              child: const Text("Continue"),
            ),
          ],
        ),
      ],
    );
  }

  /// After verifying current password, show the new password panel
  Widget _buildSecurityPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Change Password",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "New Password",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _showSecurityPanel = false;
                  _showPasswordPrompt = false;
                });
              },
              child: const Text("Back"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 36, 89, 185),
              ),
              onPressed: _saveNewPassword,
              child: const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }

  /// Logic for verifying the current password
  Future<void> _verifyCurrentPassword(String currentPassword) async {
    // Attempt real re-auth
    final bool success = await AuthService().verifyCurrentPassword(
      widget.loginEmail,
      currentPassword,
    );

    if (success) {
      setState(() {
        _showSecurityPanel = true; // Show new password panel
        _showPasswordPrompt = false; // Hide the prompt
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect password.")),
      );
    }
  }

  /// Save the new password to Auth or Firestore
  Future<void> _saveNewPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();
    // ^ If you prefer to re-prompt for the old password, you can store it in a separate variable or re-ask the user.

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password cannot be empty.")),
      );
      return;
    }

    // Call your AuthService method to actually change the password
    final result =
        await AuthService().changePassword(currentPassword, newPassword);

    if (result == null) {
      // success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully.")),
      );
      setState(() {
        _showSecurityPanel = false;
        _showPasswordPrompt = false;
      });
    } else {
      // error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)), // e.g. "Error changing password: ..."
      );
    }
  }

  /// Confirm account deletion
  Future<void> _confirmAccountDeletion() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // If using FirebaseAuth:
      // await FirebaseAuth.instance.currentUser!.delete();
      // await FirebaseFirestore.instance.collection('users').doc(widget.userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account deleted (demo)."),
        ),
      );
      Navigator.pop(context); // Close this screen
    }
  }
}
