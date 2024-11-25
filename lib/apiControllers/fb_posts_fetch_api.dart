import 'package:http/http.dart' as http;
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
        "EAAH6R2ORlvEBO2phSiJJiIUNkdeTmFbTIjhBR9ggfhtmWt1IDkZCEVk1OZCyBGHikwl0hj9joMp79P94UiiMYYRfhl9UN4KHlEHdW9UJZBPROxOwwivj27JnNNuvZBoG1Ru0YLz9FFU68CZBocahE50bRMASgAKducZAqgExz3UeD1Os2s2ZC2vtMSyF5MKZCRKfZCtQstTujcx9tjoPqc9ZCihZCEJ";

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
