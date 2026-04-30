import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // User should replace this

  Future<List<String>> generateCaptions(Uint8List imageBytes) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      
      final content = [
        Content.multi([
          DataPart('image/jpeg', imageBytes),
          TextPart("Generate 3-5 creative and engaging Instagram captions for this image. Provide only the captions, separated by newlines."),
        ])
      ];

      final response = await model.generateContent(content);
      
      if (response.text != null) {
        return response.text!
            .split('\n')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .toList();
      }
      return ["Awesome click!", "Keep shining!", "Vibe check!"];
    } catch (e) {
      print("AI Error: $e");
      return ["Error generating captions. Try writing your own!"];
    }
  }
}
