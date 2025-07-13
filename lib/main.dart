import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libri',
      theme: ThemeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  bool holi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'L I B R I',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: "Courier New",
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: const Color.fromARGB(255, 2, 54, 145),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 150, 201, 243),
      ),
      bottomNavigationBar: holi
          ? NavigationBar(
              backgroundColor: const Color.fromARGB(255, 150, 201, 243),
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              indicatorColor: Colors.white,
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.library_books, size: 25),
                  icon: Icon(Icons.library_books_outlined, size: 25),
                  label: 'MY LIBRARY',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.favorite_outlined, size: 25),
                  icon: Icon(Icons.favorite_border, size: 25),
                  label: 'WISHES',
                ),
              ],
            )
          : SizedBox(),
      body: holi
          ? <Widget>[
              /// Home page
              ListView.separated(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text('Book $index'),
                    subtitle: Text('Author $index'),
                    leading: Icon(Icons.bookmark),
                    children: [
                      Column(children: [Text('Overview $index')]),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 1,
                    color: const Color.fromARGB(255, 150, 201, 243),
                  );
                },
              ),

              /// Messages page
              ListView.separated(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text('Wished book $index'),
                    subtitle: Text('Author $index'),
                    leading: Icon(Icons.bookmark),
                    children: [
                      Column(children: [Text('Overview $index')]),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    thickness: 1,
                    color: const Color.fromARGB(255, 150, 201, 243),
                  );
                },
              ),
            ][currentPageIndex]
          : AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "While data is loading,\n Improve you are holy.holyf",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  TextField(
                    onSubmitted: (value) {
                      if (value == 'not volkov') {
                        setState(() {
                          holi = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('It is DEFINETLY not $value'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hint: Text(
                        'The best book man is...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
