import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class StorageService {
  /// Resizes the image to max 600x600 and converts to a base64 JPEG data URI.
  /// This is stored directly in Firestore — no external service needed, no CORS issues.
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    try {
      // Decode the raw bytes to an image object
      img.Image? original = img.decodeImage(file);
      if (original == null) throw Exception('Could not decode image');

      // Resize: profile pics → 400x400, posts → 800x800
      int maxSize = isPost ? 800 : 400;
      img.Image resized = img.copyResize(
        original,
        width: original.width > maxSize ? maxSize : original.width,
        maintainAspect: true,
      );

      // Encode back to JPEG at 80% quality to keep it small
      Uint8List compressed = Uint8List.fromList(
        img.encodeJpg(resized, quality: 80),
      );

      String base64Str = base64Encode(compressed);
      return 'data:image/jpeg;base64,$base64Str';
    } catch (e) {
      // If anything fails, return the original as-is (best effort)
      String base64Str = base64Encode(file);
      return 'data:image/jpeg;base64,$base64Str';
    }
  }
}
