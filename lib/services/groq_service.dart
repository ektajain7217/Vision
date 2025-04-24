import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class GroqService {
  final String apiKey;

  // Load the API key from environment variables
  GroqService({String? apiKey})
      : apiKey = apiKey ?? dotenv.get('GROQ_API_KEY', fallback: 'default_api_key');

  Future<String> generateResponse(List<Map<String, String>> messages) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': Constants.llama4ModelId,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'Sorry, I encountered an error. Please try again later.';
      }
    } catch (e) {
      print('Exception: $e');
      return 'Sorry, I encountered an error. Please try again later.';
    }
  }
}
