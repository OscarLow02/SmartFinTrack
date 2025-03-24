import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:smart_fintrack/firebase_options.dart';
import 'package:smart_fintrack/screens/admin/systemmonitor/monitorfunction.dart';
import 'package:smart_fintrack/screens/statistics/stats_main.dart';
import 'package:smart_fintrack/screens/user/auth_selection.dart';
import 'package:smart_fintrack/services/date_provider.dart';
import 'package:provider/provider.dart';
import 'package:smart_fintrack/screens/transactions/transactions_main.dart';
import 'package:smart_fintrack/screens/settings/settings_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    // track the error in Firestore
    logErrorToFirestore(errorDetails.exception, errorDetails.stack!);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => DateProvider()), // ✅ Register DateProvider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthSelection(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 0 = Transactions, 1 = Stats

  final List<Widget> _pages = [
    TransactionsPage(),
    const StatsMain(),
    SettingsMain(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent unnecessary reload

    setState(() {
      _selectedIndex = index; // Change the displayed page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Trans.",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_rounded),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
