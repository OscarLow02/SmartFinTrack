import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user ID
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Fetch transactions for a specific month
  Stream<QuerySnapshot> getTransactionsForTransactions(DateTime selectedDate) {
    if (userId == null) return const Stream.empty();

    String startOfMonth =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-01";
    String endOfMonth =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-31";

    return _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('dateTime', isGreaterThanOrEqualTo: startOfMonth)
        .where('dateTime', isLessThanOrEqualTo: endOfMonth)
        .snapshots();
  }

  Future<Map<String, Map<String, dynamic>>> getTransactionsForStatistics({
    required DateTime selectedDate,
    required String period, // "Monthly" or "Yearly"
    required String type, // "Income" or "Expense"
  }) async {
    if (userId == null) return {};

    Query query = _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('type', isEqualTo: type); // Filter by Income or Expense

    if (period == "Monthly") {
      String monthStart =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-01";
      String monthEnd =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-31";

      query = query
          .where('dateTime', isGreaterThanOrEqualTo: monthStart)
          .where('dateTime', isLessThanOrEqualTo: monthEnd);
    } else if (period == "Yearly") {
      String yearStart = "${selectedDate.year}-01-01";
      String yearEnd = "${selectedDate.year}-12-31";

      query = query
          .where('dateTime', isGreaterThanOrEqualTo: yearStart)
          .where('dateTime', isLessThanOrEqualTo: yearEnd);
    }

    QuerySnapshot snapshot = await query.get();

    // Use the document ID as the key to preserve duplicates
    Map<String, Map<String, dynamic>> transactionsMap = {};
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      transactionsMap[doc.id] = {
        "account": data["account"] ?? "Unknown",
        "amount": data["amount"] ?? 0.0,
        "category": data["category"] ?? "Uncategorized",
        "dateTime": data["dateTime"] ?? "",
        "imagePath": data["imagePath"] ?? "",
        "note": data["note"] ?? "",
        "type": data["type"] ?? "Unknown",
      };
    }
    return transactionsMap;
  }

  // Fetch budget data
  Future<DocumentSnapshot> getBudget(String type) {
    if (userId == null) throw Exception("User not logged in");

    return _db
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc(type)
        .get();
  }

  // Fetch notes
  Stream<QuerySnapshot> getNotes() {
    if (userId == null) return const Stream.empty();

    return _db.collection('users').doc(userId).collection('notes').snapshots();
  }
}
