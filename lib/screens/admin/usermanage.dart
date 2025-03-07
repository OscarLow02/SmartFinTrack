//import 'package:assignment_admin/screens/admin/bottom_bar.dart';
import 'package:smart_fintrack/screens/admin/userdetails.dart';
import 'package:smart_fintrack/services/auth_service.dart';
import 'package:flutter/material.dart';

class UserManage extends StatefulWidget {
  const UserManage({super.key});

  @override
  State<UserManage> createState() => _UserManageState();
}

class _UserManageState extends State<UserManage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            onPressed: () {
              //_showFilterDialog();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: AuthService().getUsersInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("An error occurred."));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No users found."));
          }

          List<Map<String, dynamic>> users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    user["username"][0].toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  user["username"] ?? "Unknown",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(user["role"]),
                onTap: () {
                  // Navigate to user details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetails(),
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

  // Function to show filter options
  // void _showFilterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Filter Users"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             RadioListTile(
  //               title: Text("All"),
  //               value: "All",
  //               groupValue: _selectedFilter,
  //               onChanged: (value) {
  //                 setState(() {
  //                   _selectedFilter = value.toString();
  //                 });
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             RadioListTile(
  //               title: Text("Admin"),
  //               value: "Admin",
  //               groupValue: _selectedFilter,
  //               onChanged: (value) {
  //                 setState(() {
  //                   _selectedFilter = value.toString();
  //                 });
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             RadioListTile(
  //               title: Text("User"),
  //               value: "User",
  //               groupValue: _selectedFilter,
  //               onChanged: (value) {
  //                 setState(() {
  //                   _selectedFilter = value.toString();
  //                 });
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
