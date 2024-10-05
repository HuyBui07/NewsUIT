import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> detectTag(String articleText) async {
  final url = Uri.parse('https://api.openai.com/v1/completions');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'gpt-3.5-turbo',
      'prompt':
          'Classify this into one of these: "Học vụ", "Thông báo", "Tuyển dụng". Article: $articleText',
      'max_tokens': 20,
      'temperature': 0,
    }),
  );

  print(response.body);
}
