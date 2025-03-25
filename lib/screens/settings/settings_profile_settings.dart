import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_fintrack/services/auth_service.dart';

class SettingsProfileSettings extends StatefulWidget {
  final String userId;

  const SettingsProfileSettings({Key? key, required this.userId})
      : super(key: key);

  @override
  State<SettingsProfileSettings> createState() =>
      _SettingsProfileSettingsState();
}

class _SettingsProfileSettingsState extends State<SettingsProfileSettings> {
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();

  String _email = "";
  String _profilePicAsset = "assets/user_icon.webp"; // default picture

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      // 1. Get the user data from Firestore
      final data = await _authService.getUserProfile(widget.userId);

      if (data != null) {
        setState(() {
          _usernameController.text = data["username"] ?? "";
          _email = data["email"] ?? "";

          // If Firestore has a 'profilePic' field, use it; otherwise, keep default
          if (data["profilePic"] != null &&
              data["profilePic"].toString().isNotEmpty) {
            _profilePicAsset = data["profilePic"];
          }
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> _saveProfileSettings() async {
    try {
      // 2. Update Firestore with the new username (and optionally the profilePic if needed)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        "username": _usernameController.text.trim(),
        "profilePic": _profilePicAsset,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully.")),
      );

      // Return the updated username back to the previous screen.
      Navigator.pop(context, _usernameController.text.trim());
    } catch (e) {
      print("Error saving profile settings: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  /// Shows a bottom sheet with multiple icons to choose from
  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // List of available icons
        final iconPaths = [
          "assets/user_icon.webp",
          "assets/male_1_icon.png",
          "assets/male_2_icon.webp",
          "assets/male_3_icon.png",
          "assets/female_1_icon.png",
          "assets/female_2_icon.png",
          "assets/female_3_icon.png",
        ];

        return ListView.builder(
          shrinkWrap: true,
          itemCount: iconPaths.length,
          itemBuilder: (context, index) {
            final iconPath = iconPaths[index];
            return ListTile(
              leading: Image.asset(iconPath, width: 40, height: 40),
              title: Text(iconPath.split('/').last), // e.g., "male_1_icon.png"
              onTap: () async {
                setState(() {
                  _profilePicAsset = iconPath;
                });

                // 3. Update Firestore with the chosen icon
                await _authService.updateProfilePicture(
                    widget.userId, iconPath);

                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
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
          "Profile Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _changeProfilePicture,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(_profilePicAsset),
              ),
            ),
            const SizedBox(height: 16),

            // Username
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),
            const SizedBox(height: 16),

            // Email (read-only)
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: _email,
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _saveProfileSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 36, 89, 185),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
