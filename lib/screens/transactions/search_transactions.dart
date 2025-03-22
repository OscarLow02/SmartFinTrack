import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_transactions.dart';
import 'transaction_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResults = [];

  void _searchTransactions(String query) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    String userId = user.uid;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('note', isGreaterThanOrEqualTo: query)
        .where('note', isLessThanOrEqualTo: "$query\uf8ff")
        .get();

    setState(() {
      _searchResults = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search Transactions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 89, 185),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by note...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _searchTransactions, // ✅ Search as user types
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(child: Text("No matching transactions"))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        var transaction = _searchResults[index].data()
                            as Map<String, dynamic>;
                        String docId = _searchResults[index].id;
                        String note = transaction['note'] ?? "No note";
                        double amount =
                            (transaction['amount'] as num).toDouble();
                        String date = transaction['dateTime'];

                        return TransactionCard(
                          transaction: _searchResults[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditScreen(
                                    currentTransaction: _searchResults[index]),
                              ),
                            );
                          },
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
