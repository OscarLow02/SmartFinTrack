import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Transactions"),
            centerTitle: true,
            backgroundColor: Colors.cyan,
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
                  children: [
                    Icon(Icons.directions_car),
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
