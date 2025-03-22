import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> logErrorToFirestore(dynamic exception, StackTrace stackTrace) async {
  try {
    await FirebaseCrashlytics.instance.recordError(exception, stackTrace);

    //save error to firestore
    await FirebaseFirestore.instance.collection('crash_reports').add({
      'error': exception.toString(),
      'stack_trace': stackTrace.toString(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Failed to log error: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchCrashReports() async {
  try{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('crash_reports')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print('Error fetching crash reports: $e');
    return [];
  }
}