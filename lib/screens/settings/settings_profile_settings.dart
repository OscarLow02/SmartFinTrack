import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String _email = "";
  String _profilePicAsset = "assets/profile_default.png"; // default picture

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _usernameController.text = data["username"] ?? "";
          _email = data["email"] ?? "";
          // If you store a profilePic key, load that
          // _profilePicAsset = data["profilePic"] ?? "assets/profile_default.png";
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> _saveProfileSettings() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        "username": _usernameController.text.trim(),
        // "profilePic": _profilePicAsset,
        // Email usually not changed unless you handle re-auth
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully.")),
      );
    } catch (e) {
      print("Error saving profile settings: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _changeProfilePicture() {
    // For a fixed set of assets, you might present a dialog or a new screen
    // with options like "assets/profile1.png", "assets/profile2.png", etc.
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading:
                  Image.asset("assets/profile1.png", width: 40, height: 40),
              title: const Text("Profile 1"),
              onTap: () {
                setState(() {
                  _profilePicAsset = "assets/profile1.png";
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  Image.asset("assets/profile2.png", width: 40, height: 40),
              title: const Text("Profile 2"),
              onTap: () {
                setState(() {
                  _profilePicAsset = "assets/profile2.png";
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
