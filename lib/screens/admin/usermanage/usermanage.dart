import 'package:smart_fintrack/screens/admin/usermanage/searchuser.dart';
import 'package:smart_fintrack/screens/admin/usermanage/userdetails.dart';
import 'package:smart_fintrack/services/auth_service.dart';
import 'package:flutter/material.dart';

class UserManage extends StatefulWidget {
  const UserManage({super.key});

  @override
  State<UserManage> createState() => _UserManageState();
}

class _UserManageState extends State<UserManage> {
  String? selectedRole;
  String? selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SearchUser()),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            onPressed: filterUser,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AuthService().getUsersInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("An error occurred."));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          List<Map<String, dynamic>> users = snapshot.data!;

          // Apply filters
          if (selectedRole != null) {
            users = users.where((user) => user["role"] == selectedRole).toList();
          }
          if (selectedStatus != null) {
            users = users.where((user) => user["status"] == selectedStatus).toList();
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    user["username"][0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  user["username"] ?? "Unknown",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user["role"]),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetails(userData: user),
                    ),
                  );
                },
              );
            },
          );
        },
      )
    );
  }

  // Function to filter users
  void filterUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text("Filter Users")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Role Dropdown
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: "Filter by Role"),
                items: ["All", "admin", "user"]
                    .map((role) => DropdownMenuItem(
                          value: role == "All" ? null : role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
              const SizedBox(height: 10),

              // Status Dropdown
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: "Filter by Status"),
                items: ["All", "Active", "Suspended"]
                    .map((status) => DropdownMenuItem(
                          value: status == "All" ? null : status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {}); // Refresh user list with selected filters
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }
}
