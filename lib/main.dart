import 'dart:core';
import 'dart:typed_data';
import 'package:fade_animation_delayed/fade_animation_delayed.dart';
import 'package:flutter/cupertino.dart';
import 'package:libri/backend/firestore.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:libri/backend/cloudinary.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  final GlobalKey<FadeAnimationDelayedState> delayedDisplayKey =
      GlobalKey<FadeAnimationDelayedState>();

  final darkBlue = Color.fromARGB(255, 2, 54, 145);

  final lightBlue = const Color.fromARGB(255, 150, 201, 243);

  int currentPageIndex = 0;
  bool holi = false;
  Uint8List? img;
  String bookname = '';
  String author = '';
  String overview = '';
  String image = '';
  int price = 0;
  double rating = 0.0;
  String status = 'Planned';

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  List<Map<String, dynamic>> books = [];

  Future<void> loadBooks() async {
    final fetchedBooks = await getAllBooks(); // or getAllBooks()
    setState(() {
      books = fetchedBooks;
    });
  }

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
            color: darkBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: lightBlue,
      ),
      bottomNavigationBar: holi
          ? NavigationBar(
              backgroundColor: lightBlue,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              indicatorColor: Colors.white,
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(
                    CupertinoIcons.collections_solid,
                    size: 25,
                    color: Color.fromARGB(255, 2, 54, 145),
                  ),
                  icon: Icon(
                    CupertinoIcons.collections,
                    size: 25,
                    color: Color.fromARGB(255, 2, 54, 145),
                  ),
                  label: 'MY LIBRARY',
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.favorite_outlined,
                    size: 25,
                    color: Color.fromARGB(255, 2, 54, 145),
                  ),
                  icon: Icon(
                    Icons.favorite_border,
                    size: 25,
                    color: Color.fromARGB(255, 2, 54, 145),
                  ),
                  label: 'WISHES',
                ),
              ],
            )
          : SizedBox(),
      floatingActionButton: holi && currentPageIndex == 0
          ? FloatingActionButton(
              backgroundColor: lightBlue,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                            left: 16,
                            right: 16,
                            top: 24,
                          ),
                          child: SingleChildScrollView(
                            child: Form(
                              child: Column(
                                spacing: 20,
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                                      lightBlue,
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
                                                      lightBlue,
                                                    ),
                                              ),
                                              icon: Icon(
                                                Icons
                                                    .drive_folder_upload_rounded,
                                                size: 40,
                                              ),
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        color: darkBlue,
                                        fontSize: 16,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: darkBlue,
                                          width: 2,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: lightBlue,
                                          width: 2,
                                        ),
                                      ),
                                      labelText: 'Book name',
                                    ),
                                    onChanged: (value) => {
                                      setState(() {
                                        bookname = value;
                                      }),
                                    },
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        color: darkBlue,
                                        fontSize: 16,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: darkBlue,
                                          width: 2,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: lightBlue,
                                          width: 2,
                                        ),
                                      ),
                                      labelText: 'Author',
                                    ),
                                    onChanged: (value) => {
                                      setState(() {
                                        author = value;
                                      }),
                                    },
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        color: darkBlue,
                                        fontSize: 16,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: darkBlue,
                                          width: 2,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: lightBlue,
                                          width: 2,
                                        ),
                                      ),
                                      labelText: 'Overview',
                                    ),
                                    onChanged: (value) => {
                                      setState(() {
                                        overview = value;
                                      }),
                                    },
                                    keyboardType: TextInputType.multiline,
                                  ),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                        color: darkBlue,
                                        fontSize: 16,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: darkBlue,
                                          width: 2,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: lightBlue,
                                          width: 2,
                                        ),
                                      ),
                                      labelText: 'Price',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => {
                                      setState(() {
                                        price = int.tryParse(value) ?? 0;
                                      }),
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Satus: ',
                                        style: TextStyle(
                                          fontFamily: "Courier New",
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      RadioGroup(
                                        decoration: RadioGroupDecoration(
                                          activeColor: darkBlue,
                                          labelStyle: TextStyle(fontSize: 16)
                                        ),
                                        onChanged: (value) => {
                                          setState(() {
                                            status = value!;
                                          }),
                                        },
                                        values: ['Done', 'Reading', 'Planned'],
                                        indexOfDefault: status == 'Done'
                                            ? 0
                                            : status == 'Reading'
                                            ? 1
                                            : 2,
                                        orientation:
                                            RadioGroupOrientation.horizontal,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 10,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Holy rating: ',
                                        style: TextStyle(
                                          fontFamily: "Courier New",
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      StarRating(
                                        color: darkBlue,
                                        allowHalfRating: true,
                                        rating: rating,
                                        onRatingChanged: (value) => {
                                          setState(() {
                                            rating = value;
                                          }),
                                        },
                                      ),
                                    ],
                                  ),
                                  OutlinedButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                        lightBlue,
                                      ),
                                      side: WidgetStateProperty.all(
                                        BorderSide(width: 0),
                                      ),
                                      textStyle: WidgetStateProperty.all(
                                        TextStyle(
                                          color: darkBlue,
                                          fontFamily: 'Courier New',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (img != null) {
                                        if (bookname != '' &&
                                            author != '' &&
                                            overview != '') {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Center(
                                                child: FadeAnimationDelayed(
                                                  animationDuration: Duration(
                                                    milliseconds: 50,
                                                  ),
                                                  animationType:
                                                      AnimationType.fadeIn,
                                                  key: delayedDisplayKey,
                                                  repeat: true,
                                                  child: Image.asset(
                                                    width: 150,
                                                    height: 150,
                                                    'assets/loading.png',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                          bool result = await addBook(
                                            bookname,
                                            author,
                                            overview,
                                            price,
                                            rating,
                                            status,
                                            img!,
                                          );
                                          if (result) {
                                            await loadBooks();
                                            setState(() {
                                              img = null;
                                              rating = 0;
                                              status = 'Planned';
                                            });
                                            Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pop();
                                          }
                                          Navigator.of(context).pop();
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text("Fill all fields"),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Please pick an image first",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Add new book to library',
                                      style: TextStyle(color: darkBlue),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Stack(
                children: [
                  Icon(CupertinoIcons.book, size: 34, color: Colors.white),
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Icon(Icons.add, size: 24, color: Colors.black),
                  ),
                ],
              ),
            )
          : SizedBox(),
      body: holi
          ? <Widget>[
              /// Home page
              RefreshIndicator(
                onRefresh: () async {
                  await loadBooks();
                },
                child: ListView.separated(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ExpansionTile(
                      title: Text(book['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book['author']),
                          Text('Status: ${book['status']}'),
                        ],
                      ),
                      leading: Image(
                        height: 100,
                        fit: BoxFit.fitWidth,
                        image: NetworkImage(
                          'https://res.cloudinary.com/duzlbgwpt/image/upload/v1752573157/${book['image']}.jpg',
                        ),
                      ),
                      children: [
                        Column(children: [Text(book['overview'])]),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(thickness: 1, color: lightBlue);
                  },
                ),
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
                  return Divider(thickness: 1, color: lightBlue);
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
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),

                      labelText: 'The best book man is...',
                    ),
                    onSubmitted: (value) {
                      if (value.contains('not volkov')) {
                        setState(() {
                          holi = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: lightBlue,
                            content: Text('It is DEFINETLY not $value'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
