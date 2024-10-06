import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'dart:convert';
import 'package:intl/intl.dart';

class Posts {
  final String description;
  final String createdTime;
  final String fullPicture;

  Posts({
    required this.description,
    required this.createdTime,
    required this.fullPicture,
  });

  factory Posts.fromJson(Map<String, dynamic> json) {
    return Posts(
      description: json['description'],
      createdTime: json['created_time'],
      fullPicture: json['full_picture'],
    );
  }
}

class PostsService {
  static final PostsService _postsService = PostsService();

  final appID = "2262716884108751";
  final secretKey = "153d1aee4eeee9c7618753abaad4ea0c";

  factory PostsService() {
    return _postsService;
  }

  static Future<List<Posts>> fetchFanPagePosts() async {
    print('Fetching posts');
    var accessToken =
        "EAAH6R2ORlvEBO0wRsji9M32bZBZAGDpspwxB2dCpNJCCCe2bpTI7FBankBED4WCo2RHtOZC9Vw1mI5OpjceuhtKFiMpyFAjnNgGF5pZB3GtJZCycu517oWqBMlK0hQ8zre94L5ZA3m0D9vzO1OZBS7t27SRbfbpnSm1JsZAnYKb8dJZBoNZByltQrtepA3n6ZB8QxtmihqIozxhphw1urMZASluxAcgA";

    var pageId = "431464436719562";

    final url =
        'https://graph.facebook.com/$pageId/posts?fields=message,full_picture, created_time&access_token=$accessToken';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Posts> posts = (data['data'] as List).map((post) {
        DateTime createdTime = DateTime.parse(post['created_time']);
        // Format the DateTime object into a common date expression
        String formattedDate = DateFormat('dd/MM/yyyy').format(createdTime);
        return Posts(
          description: post['message'] ?? 'No description',
          createdTime: formattedDate,
          fullPicture: post['full_picture'] ?? 'No image',
        );
      }).toList();

      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
