import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class News {
  final String id;
  final String title;
  final String body;
  final String publishedAt;
  final List<String> tags;
  final String about;

  News(
      {required this.id,
      required this.title,
      required this.body,
      required this.publishedAt,
      required this.tags,
      required this.about});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      publishedAt: json['publishedAt'],
      tags: json['tags'],
      about: json['about'],
    );
  }

  @override
  String toString() {
    return 'News{id: $id, title: $title, body: $body, publishedAt: $publishedAt, tags: $tags}';
  }
}

class NewsService {
  static final NewsService _newsService = NewsService();

  factory NewsService() {
    return _newsService;
  }

  static Future<List<News>> fetchNews(int? pageNumber) async {
    final response = await http.get(Uri.parse(
        'https://daa.uit.edu.vn/thongbaochinhquy?page=${pageNumber}'));
    if (response.statusCode == 200) {
      Document document = parser.parse(response.body);
      List<Element> articles = document.getElementsByTagName('article');
      List<News> news = articles.map((article) {
        Element? spanElement =
            article.querySelector('span[property="dc:date dc:created"]');
        String text = spanElement?.text ?? 'Unknown';
        String title = article.getElementsByTagName('h2').first.text;
        List<String> tags = categorizeNew(title);

        return News(
          id: article.attributes['id']!,
          title: title,
          body: article.getElementsByTagName('p').first.text,
          publishedAt: text,
          tags: tags,
          about: article.attributes['about']!,
        );
      }).toList();

      return news;
    } else {
      throw Exception('Failed to load news');
    }
  }

  static List<String> categorizeNew(String title) {
    // Từ khóa theo từng loại tag
    Map<String, List<String>> keywordTags = {
      'Học vụ': ['lịch thi', 'kế hoạch', 'học phí'],
      'Sự kiện': ['tuyển sinh', 'khóa học'],
      'Thông báo': ['thông báo'],
    };

    List<String> tags = [];

    // Quét title và thêm tag tương ứng
    keywordTags.forEach((tag, keywords) {
      for (var keyword in keywords) {
        if (title.toLowerCase().contains(keyword.toLowerCase())) {
          tags.add(tag);
          break; // Ngừng sau khi tìm thấy từ khóa để tránh trùng lặp tag
        }
      }
    });

    if (tags.isEmpty) {
      tags.add('Khác');
    }

    return tags;
  }

  static Future<String> fetchNewsContent(String about) async {
    final response = await http.get(Uri.parse("https://daa.uit.edu.vn/$about"));
    if (response.statusCode == 200) {
      Document document = parser.parse(response.body);
      Element? contentElement = document.querySelector('article');
      if (contentElement != null) {
        return contentElement.innerHtml;
      } else {
        throw Exception('Content div not found');
      }
    } else {
      throw Exception('Failed to load news content');
    }
  }
}
