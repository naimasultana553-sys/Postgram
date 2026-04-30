import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StorageService {
  // Adding image to Imgur to bypass Firebase Storage limitations
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    
    try {
      String base64Image = base64Encode(file);
      var response = await http.post(
        Uri.parse('https://api.imgur.com/3/image'),
        headers: {
          'Authorization': 'Client-ID 546c25a59c58ad7',
        },
        body: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        return responseData['data']['link'];
      } else {
        throw Exception("Failed to upload image to Imgur: ${response.body}");
      }
    } catch (e) {
      print(e.toString());
      throw Exception("Image upload failed");
    }
  }
}
