import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'daily_transactions.dart';

// Variables to store document details
String account = "";
String amount = "";
String category = "";
Timestamp dateTime = Timestamp.now();
String date = "";
String note = "";
String type = "";

// For transfer transactions
String from = "";
String to = "";

List<List<String>> allTransactions = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  fetchTransactions();
  runApp(MyApp());
}

void fetchTransactions() async {
  // Reference to Firestore collection
  CollectionReference transactions =
      FirebaseFirestore.instance.collection("transactions");

  // Get all documents
  QuerySnapshot querySnapshot = await transactions.get();

  // Loop through each document
  for (var doc in querySnapshot.docs) {
    amount = doc["amount"].toString();
    dateTime = doc["dateTime"];
    note = doc["note"];
    type = doc["type"];

    if (doc["type"] != "transfer") {
      category = doc["category"];
    } else {
      from = doc["from"];
      to = doc["to"];
    }
    // Convert Timestamp to DateTime
    String date = dateTime.toDate().toString();

    // Create a list for the current document

    List<String> transactionData;

    if (doc["type"] != "transfer") {
      transactionData = [amount, category, date, note, type];
    } else {
      transactionData = [amount, from, to, date, note, type];
    }

    // Add this document's data to the main list
    allTransactions.add(transactionData);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final Color _selectedColor = const Color.fromARGB(255, 36, 89, 185);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Transactions"),
            centerTitle: true,
            backgroundColor: _selectedColor,
            leading: IconButton(
              onPressed: () {},
              icon: Icon(Icons.search),
            ),
          ),
          body: Column(
            mainAxisSize: MainAxisSize
                .min, // Prevents Column from taking unnecessary space
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_back_ios_new_outlined),
                  ),
                  Text("Mar 2023"),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_forward_ios_outlined),
                  ),
                ],
              ),
              TabBar(
                tabs: [
                  Tab(text: "Daily"),
                  Tab(text: "Calender"),
                  Tab(text: "Monthly"),
                  Tab(text: "Desc."),
                ],
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    dailyTransactions(),
                    Icon(Icons.directions_transit),
                    Icon(Icons.directions_bike),
                    Icon(Icons.directions_bike),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.cyan,
            child: Icon(Icons.add),
            onPressed: () {},
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {},
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: "Trans.",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_graph_rounded),
                label: "Stats",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
