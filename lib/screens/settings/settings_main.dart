import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_fintrack/screens/settings/view_mode.dart';
import 'settings_login_security.dart';
import 'settings_profile_settings.dart';
import 'settings_privacy_policy.dart';
import 'settings_helpnsupport.dart';
import 'package:smart_fintrack/services/auth_service.dart';

class SettingsMain extends StatefulWidget {
  const SettingsMain({Key? key}) : super(key: key);

  @override
  State<SettingsMain> createState() => _SettingsMainState();
}

class _SettingsMainState extends State<SettingsMain> {
  String _userId = "";
  String _username = "";
  String _email = "";
  String _profilePicAsset = 'assets/user_icon.webp';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    // Get the userId from AuthService
    final String? userId = AuthService().getCurrentUserId();
    if (userId == null) {
      // Handle no user logged in
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userId = userId;
          _username = data["username"] ?? "";
          _email = data["email"] ?? "";
          _profilePicAsset = data["profilePic"] ?? 'assets/user_icon.webp';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() {
    AuthService().signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 36, 89, 185),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewNotification()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage(_profilePicAsset),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Settings List
              Column(
                children: [
                  _buildSettingsItem(
                    icon: Icons.settings,
                    title: "Login & Security",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsLoginSecurity(
                            userId: _userId,
                            loginEmail: _email,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.person,
                    title: "Profile settings",
                    onTap: () async {
                      final updatedUsername = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SettingsProfileSettings(userId: _userId),
                        ),
                      );
                      if (updatedUsername != null &&
                          updatedUsername is String) {
                        setState(() {
                          _username = updatedUsername;
                        });
                      }
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy policy",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsPrivacyPolicy(),
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: "Help and support",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsHelpNSupport(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Log Out
              Container(
                child: _buildSettingsItem(
                  icon: Icons.logout,
                  title: "Log out",
                  titleColor: Colors.red,
                  onTap: _logout,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: titleColor ?? Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
