import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
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
  Uint8List? img;

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();

    // Request permissions if necessary
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.photos
          .request(); // or Permission.storage on older Androids
    }

    final XFile? file = await _imagePicker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    }
    return null;
  }

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
      floatingActionButton: holi && currentPageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        // <-- local setState here!
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 16,
                            right: 16,
                            top: 24,
                          ),
                          child: Form(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Book name:'),
                                TextField(),
                                Text('Author'),
                                TextField(),
                                Text('Overview'),
                                TextField(
                                  minLines: 1,
                                  maxLines: 3,
                                  keyboardType: TextInputType.multiline,
                                ),
                                Text('Price'),
                                TextField(keyboardType: TextInputType.number),
                                img != null
                                    ? Stack(
                                        children: [
                                          Image.memory(
                                            img!,
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                          Container(
                                            width: 200,
                                            height: 200,
                                            color: Color.fromARGB(
                                              112,
                                              31,
                                              31,
                                              31,
                                            ),
                                          ),
                                          Positioned(
                                            left: 50,
                                            top: 50,
                                            child: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  // <-- use this setState
                                                  img = null;
                                                });
                                              },
                                              icon: Icon(
                                                Icons.change_circle_outlined,
                                                size: 100,
                                                color: Color.fromARGB(
                                                  225,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        spacing: 20,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              final bytes = await pickImage(
                                                ImageSource.camera,
                                              );
                                              setState(() {
                                                img = bytes;
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                    Colors.blue,
                                                  ),
                                            ),
                                            icon: Icon(
                                              Icons.camera_alt,
                                              size: 40,
                                            ),
                                            color: Colors.white,
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              final bytes = await pickImage(
                                                ImageSource.gallery,
                                              );
                                              setState(() {
                                                img = bytes;
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                    Colors.blue,
                                                  ),
                                            ),
                                            icon: Icon(
                                              Icons.drive_folder_upload_rounded,
                                              size: 40,
                                            ),
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: Text('Add new book to library'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Icon(Icons.add),
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
