import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String> uploadToCloud(Uint8List img, String name) async {
  String cloudName = dotenv.env['CLOUDINARY_CLOUDNAME'] ?? '';
  final url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );
  var request = http.MultipartRequest('POST', url);
  var multipartFile = http.MultipartFile.fromBytes('file', img, filename: name);

  request.files.add(multipartFile);
  request.fields['upload_preset'] = 'flutterlibri';
  request.fields['resource_type'] = 'image';

  var response = await request.send();

  var responseBody = await response.stream.bytesToString();
  print(responseBody);

  if (response.statusCode == 200) {
    print('\nUploaded succsesfully \n');
    final Map<String, dynamic> json = jsonDecode(responseBody);
    return json['public_id'];
  } else {
    print('Failed with status ${response.statusCode} aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    return "error";
  }
}
