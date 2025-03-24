import 'package:flutter/material.dart';
import 'package:smart_fintrack/services/auth_service.dart';

class SettingsChangePassword extends StatefulWidget {
  const SettingsChangePassword({Key? key}) : super(key: key);

  @override
  State<SettingsChangePassword> createState() => _SettingsChangePasswordState();
}

class _SettingsChangePasswordState extends State<SettingsChangePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() => _isLoading = true);

    final String currentPassword = _currentPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();

    final result =
        await AuthService().changePassword(currentPassword, newPassword);

    setState(() => _isLoading = false);

    if (result == null) {
      // success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully.")),
      );
      Navigator.pop(context);
    } else {
      // error
      setState(() => _error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Current Password",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 36, 89, 185),
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
      ),
    );
  }
}
