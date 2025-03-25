import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user ID
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // 🟢 Fetch transactions with filtered (selectedDate, selectedPeriod, type)
  Future<Map<String, Map<String, dynamic>>> getFilteredTransactions({
    required String type, // "Income" or "Expense"
    DateTime? selectedDate,
    String? period, // "Monthly" or "Yearly"
  }) async {
    if (userId == null) return {};

    Query query = _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('type', isEqualTo: type);

    // If both selectedDate and period are provided, add date filters
    if (selectedDate != null && period != null) {
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
    }

    QuerySnapshot snapshot = await query.get();

    return {
      for (var doc in snapshot.docs)
        doc.id: Map<String, dynamic>.from(doc.data() as Map)
    };
  }

  // 🟢 1) Fetch budget data
  Future<Map<String, Map<String, dynamic>>> fetchBudgetData() async {
    if (userId == null) {
      throw Exception("User not logged in");
    }

    QuerySnapshot snapshot =
        await _db.collection('users').doc(userId).collection('budget').get();

    // If no documents, return empty maps
    if (snapshot.docs.isEmpty) {
      return {
        "monthlyLimit": {},
        "yearlyLimit": {},
      };
    }

    // Initialize merged maps
    Map<String, dynamic> mergedMonthly = {};
    Map<String, dynamic> mergedYearly = {};

    // Merge data from all documents
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = Map<String, dynamic>.from(doc.data() as Map);

      // Merge monthlyLimit
      Map<String, dynamic> monthlyData =
          Map<String, dynamic>.from(data["monthlyLimit"] ?? {});
      monthlyData.forEach((key, value) {
        // You can decide to overwrite or combine in a custom way.
        mergedMonthly[key] = value;
      });

      // Merge yearlyLimit
      Map<String, dynamic> yearlyData =
          Map<String, dynamic>.from(data["yearlyLimit"] ?? {});
      yearlyData.forEach((key, value) {
        mergedYearly[key] = value;
      });
    }

    return {
      "monthlyLimit": mergedMonthly,
      "yearlyLimit": mergedYearly,
    };
  }

  // 🟢 2) Update or Add Budget Data
  Future<void> updateBudgetData({
    required String periodType, // "Monthly" or "Yearly"
    required String dateKey, // e.g. "Mar 2025" or "2025"
    required double limitValue,
    required bool isDefaultBudget,
    int? actualYear, // pass in if monthly
  }) async {
    if (userId == null) {
      throw Exception("User not logged in");
    }

    // 1) Get all docs in the 'budget' collection
    QuerySnapshot snapshot =
        await _db.collection('users').doc(userId).collection('budget').get();

    DocumentReference? docRef;
    Map<String, dynamic> docData = {};

    if (snapshot.docs.isEmpty) {
      // 🟢 No budget docs => create a new doc
      docRef = _db
          .collection('users')
          .doc(userId)
          .collection('budget')
          .doc(); // auto-generated ID or use your own

      // Initialize the doc with empty monthlyLimit/yearlyLimit
      docData = {
        "monthlyLimit": <String, dynamic>{},
        "yearlyLimit": <String, dynamic>{},
      };
    } else if (snapshot.docs.length == 1) {
      // 🟢 Exactly one doc => update it
      DocumentSnapshot existingDoc = snapshot.docs.first;
      docRef = existingDoc.reference;

      // Convert to a Map<String, dynamic> with .from
      docData = Map<String, dynamic>.from(existingDoc.data() as Map);

      // Ensure the top-level keys exist as maps.
      docData["monthlyLimit"] = docData["monthlyLimit"] != null
          ? Map<String, dynamic>.from(docData["monthlyLimit"])
          : {};
      docData["yearlyLimit"] = docData["yearlyLimit"] != null
          ? Map<String, dynamic>.from(docData["yearlyLimit"])
          : {};
    } else {
      // 🟢 More than one doc => decide how to handle
      // e.g., pick the first doc, or merge all docs, etc.
      DocumentSnapshot firstDoc = snapshot.docs.first;
      docRef = firstDoc.reference;

      // If you want to merge all existing docs, you’d do something similar
      // to your fetchBudgetData() logic. For simplicity, we’ll just update
      // the first doc here:
      docData = Map<String, dynamic>.from(firstDoc.data() as Map);
      docData["monthlyLimit"] = docData["monthlyLimit"] != null
          ? Map<String, dynamic>.from(docData["monthlyLimit"])
          : {};
      docData["yearlyLimit"] = docData["yearlyLimit"] != null
          ? Map<String, dynamic>.from(docData["yearlyLimit"])
          : {};
    }

    // 2) Modify monthlyLimit or yearlyLimit as needed
    if (periodType == "Monthly") {
      Map<String, dynamic> monthlyData = docData["monthlyLimit"];
      if (isDefaultBudget) {
        // Use the year from dateKey, which might just be "2025"
        final int yearInt = int.tryParse(dateKey) ?? DateTime.now().year;
        for (var m in [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec"
        ]) {
          monthlyData["$m $yearInt"] = limitValue;
        }
      } else {
        // Single month
        monthlyData[dateKey] = limitValue;
      }
      docData["monthlyLimit"] = monthlyData;
    } else {
      // "Yearly"
      Map<String, dynamic> yearlyData = docData["yearlyLimit"];
      if (isDefaultBudget) {
        // Example: set the same limit for all years in a range
        int centerYear = int.tryParse(dateKey) ?? DateTime.now().year;
        for (int y = centerYear - 5; y <= centerYear + 5; y++) {
          yearlyData[y.toString()] = limitValue;
        }
      } else {
        // Single year
        yearlyData[dateKey] = limitValue;
      }
      docData["yearlyLimit"] = yearlyData;
    }

    // 3) Finally, write updated data back to Firestore (using merge)
    await docRef.set(docData, SetOptions(merge: true));
  }
}
