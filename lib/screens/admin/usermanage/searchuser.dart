import 'package:flutter/material.dart';
import 'package:smart_fintrack/screens/admin/bottom_bar.dart';
import 'package:smart_fintrack/screens/admin/usermanage/userdetails.dart';
import 'package:smart_fintrack/services/auth_service.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search user...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchQuery = "";
                        });
                      },
                    )
                  : null,
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => AdminBottomBar())
              );
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
      body: searchQuery.isEmpty
          ? const Center(child: Text("Type username to search...", style: TextStyle(fontSize: 18))) // No users displayed initially
          : StreamBuilder<List<Map<String, dynamic>>>(
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

                // Apply search filter
                users = users.where((user) {
                  String username = (user["username"] ?? "").toLowerCase();
                  return username.startsWith(searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No results", style: TextStyle(fontSize: 18)));
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
                      subtitle: Text(user["role"] ?? "No role"),
                      onTap: () {
                        // Navigate to user details page
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
            ),
    );
  }
}