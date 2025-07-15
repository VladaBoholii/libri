import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:libri/backend/cloudinary.dart';

var db = FirebaseFirestore.instance;

Future<bool> addBook(
  String bookname,
  String author,
  String overview,
  int price,
  double rating,
  String status,
  Uint8List img,
) async {
  try {
    var uploadedUrl = await uploadToCloud(img, bookname);
    if (uploadedUrl != 'error') {
      final docRef = db.collection('libri').doc('holi');

      // Read current data
      final doc = await docRef.get();
      Map<String, dynamic> currentData = doc.data() ?? {};

      // Next ID (as string key)
      int nextId = currentData.length;
      String nextKey = nextId.toString();

      // New book data
      final book = <String, dynamic>{
        'name': bookname,
        'author': author,
        'overview': overview,
        'image': uploadedUrl,
        'price': price,
        'rating': rating,
        'status': status,
      };

      // Merge new data into existing docr
      await docRef.set({nextKey: book}, SetOptions(merge: true));

      return true;
    } else {
      print('\nPhoto not uploaded\n');
      return false;
    }
  } catch (e) {
    print(
      'Failed to add book: ${e} aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );
    return false;
  }
}

Future<List<Map<String, dynamic>>> getAllBooks() async {
  final doc = await db.collection('libri').doc('holi').get();
  if (!doc.exists) {
    print('no doc');
    return [];
  }

  final data = doc.data();
  if (data == null) {
    print('no data');
    return [];
  }
  print(
    'aaaaaaaaaaaaaaaaaaaaaaaaa       ${data.values.map((bookData) => Map<String, dynamic>.from(bookData)).toList()} aaaaaaaaaaaaaaaaaaaaaaaaaa',
  );
  return data.values
      .map((bookData) => Map<String, dynamic>.from(bookData))
      .toList();
}
