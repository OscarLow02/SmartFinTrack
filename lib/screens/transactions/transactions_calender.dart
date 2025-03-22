import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_transactions.dart';

class Event {
  final String title;
  Event(this.title);
}

// Store all transactions in memory
final Map<String, List<Event>> allEvents = {};
final Map<String, List<Event>> displayedEvents = {};

class TableBasicsExample extends StatefulWidget {
  final DateTime selectedDate;

  const TableBasicsExample({super.key, required this.selectedDate});

  @override
  State<TableBasicsExample> createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  late DateTime _selectedDate;
  DateTime? _selectedDay;

  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedDay = _selectedDate;
    _selectedEvents = ValueNotifier([]);

    _listenForTransactions();
  }

  @override
  void didUpdateWidget(covariant TableBasicsExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        _selectedDate = widget.selectedDate;
        _selectedDay = _selectedDate;
        _filterTransactionsByMonth(_selectedDate);
      });
    }
  }

  void _listenForTransactions() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String userId = user.uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .snapshots()
        .listen((snapshot) {
      Map<String, List<Event>> updatedEvents = {};

      for (var doc in snapshot.docs) {
        String date = doc['dateTime'];
        double amount = (doc['amount'] as num).toDouble();
        String type = doc['type'] ?? "Other";
        String note = doc['note'] ?? "";

        String eventTitle = "";

        if (type == "transfer") {
          String from = doc['from'] ?? "Unknown";
          String to = doc['to'] ?? "Unknown";
          eventTitle = "Transfer: RM$amount from $from to $to ($note)";
        } else {
          String category = doc['category'] ?? "Unknown";
          eventTitle = "$type: $category - RM$amount ($note)";
        }

        updatedEvents.putIfAbsent(date, () => []).add(Event(eventTitle));
      }

      setState(() {
        allEvents.clear();
        allEvents.addAll(updatedEvents);
        _filterTransactionsByMonth(_selectedDate);
      });
    });
  }

  void _filterTransactionsByMonth(DateTime date) {
    String selectedMonth = DateFormat('yyyy-MM').format(date);

    Map<String, List<Event>> filteredEvents = {};

    for (var entry in allEvents.entries) {
      if (entry.key.startsWith(selectedMonth)) {
        filteredEvents[entry.key] = entry.value;
      }
    }

    setState(() {
      displayedEvents.clear();
      displayedEvents.addAll(filteredEvents);
      _selectedEvents.value = _getEventsForDay(_selectedDate);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    String dateKey = DateFormat('yyyy-MM-dd').format(day);
    return displayedEvents[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _selectedDate,
              calendarFormat: _calendarFormat,
              headerVisible: false,
              selectedDayPredicate: (day) => false,
              eventLoader: _getEventsForDay,
              availableGestures: AvailableGestures.none,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                todayTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  String dateKey = DateFormat('yyyy-MM-dd').format(day);
                  bool hasEvents = displayedEvents.containsKey(dateKey) &&
                      displayedEvents[dateKey]!.isNotEmpty;
                  bool isToday = isSameDay(day, DateTime.now());

                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: hasEvents && !isToday
                        ? BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  return Container(); // ✅ Removes black dots
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _selectedEvents.value = _getEventsForDay(selectedDay);
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _selectedDate = focusedDay;
                  _filterTransactionsByMonth(_selectedDate);
                });
              },
            ),
          ),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return value.isEmpty
                    ? const Center(child: Text("No events"))
                    : ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () async {
                                // ✅ Ensure user is logged in
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user == null) return;

                                String userId = user.uid;
                                String selectedDate = DateFormat('yyyy-MM-dd')
                                    .format(_selectedDay!);

                                // ✅ Extract amount from event title
                                String title = value[index].title;
                                RegExp amountRegex = RegExp(r'RM([\d.]+)');
                                Match? match = amountRegex.firstMatch(title);

                                if (match == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Invalid transaction format!')),
                                  );
                                  return;
                                }

                                double eventAmount = double.parse(
                                    match.group(1)!); // Extract RM amount

                                // ✅ Query Firestore for the exact transaction
                                QuerySnapshot snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(userId)
                                    .collection('transactions')
                                    .where('dateTime', isEqualTo: selectedDate)
                                    .get();

                                // ✅ Find transaction with the correct amount
                                var matchingDocs = snapshot.docs.where((doc) {
                                  double dbAmount =
                                      (doc['amount'] as num).toDouble();
                                  return dbAmount == eventAmount;
                                }).toList();

                                if (matchingDocs.isNotEmpty) {
                                  // ✅ Navigate to EditScreen with the first matching transaction
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditScreen(
                                        currentTransaction: matchingDocs.first,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Transaction not found!')),
                                  );
                                }
                              },
                              title: Text(value[index].title),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
