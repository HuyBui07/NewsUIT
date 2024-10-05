import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> detectTag(String articleText) async {
  const apiKey =
      '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';
  final url = Uri.parse('https://api.openai.com/v1/completions');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $apiKey',
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
