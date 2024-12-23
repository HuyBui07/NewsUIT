import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:news_uit/utils/categorizeNews.dart';

class Posts {
  final String description;
  final String createdTime;
  final String fullPicture;
  final List<String> tags;

  Posts({
    required this.description,
    required this.createdTime,
    required this.fullPicture,
    this.tags = const [],
  });

  factory Posts.fromJson(Map<String, dynamic> json) {
    return Posts(
      description: json['description'],
      createdTime: json['created_time'],
      fullPicture: json['full_picture'],
      tags: json['tags'],
    );
  }
}

class PostsService {
  static final PostsService _postsService = PostsService();

  final appID = "556659496818417";
  final secretKey = "ba792fa267286c8f88fa674b0aa36162";

  factory PostsService() {
    return _postsService;
  }

  static Future<List<Posts>> fetchFanPagePosts() async {
    print('Fetching posts');
    var accessToken =
        "EAAH6R2ORlvEBOZCIxNAZB6AvoZBLzV1jrGXp8azbqRaSG8V2On699D3ZBmrIZBbB5a40XRZB8sD9HgwUc7X08ZAkclwIRwP5GXEaMJ8ZBQnNWYIPu5h2OOHNykraWjN0QTrB53FVmdWeSwOpcpUOQMyY26Io9redbtirXPx5ZBh3rpJQzXci2ELmTZAEPiispUnlJl";

    var pageId = "431464436719562";

    final url =
        'https://graph.facebook.com/$pageId/posts?fields=message,full_picture, created_time&access_token=$accessToken';
    final response = await http.get(Uri.parse(url));
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<Posts> posts = (data['data'] as List).map((post) {
        DateTime createdTime = DateTime.parse(post['created_time']);
        // Format the DateTime object into a common date expression
        String formattedDate = DateFormat('dd/MM/yyyy').format(createdTime);
        String description = post['message'] ?? 'No description';
        List<String> tags = categorizeNew(description);
        return Posts(
          description: description,
          createdTime: formattedDate,
          fullPicture: post['full_picture'] ?? 'No image',
          tags: tags,
        );
      }).toList();

      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
