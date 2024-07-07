import 'dart:convert';
import 'package:http/http.dart' as http;

class CgptApiService {
  final String _apiKey =
      'sk-proj-4cf5W3ieCJCg3UnTkSNuT3BlbkFJzN1uNdEFk9T1k7vGrAch';
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content':
                'find the nutritional values for the food. answer with only protein and energy kcal values using this format: "p: protein e: kcal. use web serach.'
          },
          {'role': 'user', 'content': message}
        ],
        'max_tokens': 1000,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}
