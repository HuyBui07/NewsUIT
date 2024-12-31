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
        List<Element> pElements = article.getElementsByTagName('p');
        String about = "";
        if (pElements.isEmpty) {
          about = "Bấm vào để xem thêm";
        } else {
          about = pElements.first.text;
        }

        return News(
          id: article.attributes['id']!,
          title: title,
          body: about,
          publishedAt: text,
          tags: tags,
          about: article.attributes['about']!,
        );
      }).toList();

      print('Fetched ${news.length} news articles');
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

  static Future<List<News>> fetchUITNews(
      String? filter, int? pageNumber) async {
    pageNumber ??= 0;
    var url = 'https://se.uit.edu.vn/vi/tin-tức.html?start=${pageNumber * 10}';

    switch (filter) {
      case 'Học vụ':
        url += '&filter_tag%5B0%5D=1';
        break;
      case 'Tuyển dụng':
        url += '&filter_tag%5B0%5D=2';
        break;
      case 'Thông báo':
        url += '&filter_tag%5B0%5D=3';
        break;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Document document = parser.parse(response.body);
      Element? tbody = document.querySelector('tbody');
      List<Element> articles = [];
      if (tbody != null) {
        articles = tbody.getElementsByTagName('tr');
      }

      List<News> news = articles.map((article) {
        String url =
            article.getElementsByTagName('a').first.attributes['href'] ?? '';
        String title = article.getElementsByTagName('a').first.text.trim();
        String tag = categorizeUITNew(title);
        print(url);

        return News(
          id: url,
          title: title,
          body: "",
          publishedAt: "",
          tags: [tag],
          about: url,
        );
      }).toList();

      print('Fetched ${news.length} news articles from SeUIT');
      return news;
    } else {
      throw Exception('Failed to load news');
    }
  }

  static Future<String> fetchUITNewsContent(String url) async {
    final response = await http.get(Uri.parse("https://se.uit.edu.vn$url"));
    if (response.statusCode == 200) {
      Document document = parser.parse(response.body);
      Element? contentElement = document
          .getElementsByClassName('com-content-article item-page')
          .first;
      contentElement.getElementsByClassName('article-info-term')[0].remove();
      contentElement
          .getElementsByClassName('icon-calendar icon-fw')[0]
          .remove();

      String time = contentElement.getElementsByTagName('time')[0].text.trim();
      contentElement
          .getElementsByClassName('article-info text-muted')[0]
          .replaceWith(Element.html('<p>$time</p>'));

      contentElement.getElementsByTagName('img').forEach((element) {
        if (!element.attributes['src']!.startsWith('/images')) {
          element.attributes.remove('height');
          return;
        }
        element.attributes['src'] =
            'https://se.uit.edu.vn${element.attributes['src']}';
      });
      return contentElement.innerHtml;
    } else {
      throw Exception('Failed to load news content');
    }
  }

  static Future<String> fetchUITNewTime(String url) async {
    final response = await http.get(Uri.parse("https://se.uit.edu.vn$url"));
    if (response.statusCode == 200) {
      Document document = parser.parse(response.body);
      Element? timeElement = document.getElementsByTagName('time').first;
      return timeElement.text.trim();
    } else {
      throw Exception('Failed to load news content');
    }
  }

  static String categorizeUITNew(String title) {
    // Từ khóa theo từng loại tag
    Map<String, List<String>> keywordTags = {
      'Sự kiện': [
        'sự kiện',
        'event',
        'hội thảo',
        'workshop',
        'seminar',
        'conference',
        'triển lãm',
        'exhibition',
        'giao lưu',
        'meetup',
        'họp mặt',
        'networking',
        'lễ hội',
        'festival',
        'lễ tốt nghiệp',
      ],
      'Tuyển dụng - Học Bổng': [
        'tuyển dụng',
        'tuyển',
        'thực tập',
        'internship',
        'career',
        'job',
        'nhân sự',
        'employment',
        'hiring',
        'tuyển sinh viên',
        'tuyển dụng tháng',
        'học bổng',
        'scholarship',
        'trao học bổng',
        'award',
        'bursary',
        'grant',
        'fellowship',
        'financial aid',
        'dành cho sinh viên',
        'sinh viên có hoàn cảnh khó khăn'
      ],
      'Học vụ': [
        'lịch thi',
        'kế hoạch',
        'học phí',
        'học vụ',
        'đăng ký học',
        'đăng ký môn',
        'đăng ký lớp',
        'đăng ký học phần',
        'đăng ký tín chỉ',
        'đăng ký học kỳ',
        'đăng ký học phần',
        'đăng ký học tập',
        'đăng ký học lại',
        'đăng ký học bù',
        'đăng ký học hè',
        'đăng ký học chuyên ngành',
        'đăng ký học chương trình',
        'đăng ký học chính quy',
        'đăng ký học tín chỉ',
        'đăng ký học phần tự chọn',
        'đăng ký học phần bắt buộc',
        'đăng ký học phần bổ trợ',
        'đăng ký học phần chuyên ngành',
        'đăng ký học phần chương trình',
        'đăng ký học phần chính quy',
        'đăng ký học phần tín chỉ',
        'đăng ký học phần tự chọn',
        'đăng ký học phần bắt buộc',
        'đăng ký học phần bổ trợ',
        'đăng ký học phần chuyên ngành',
        'đăng ký học phần chương trình',
        'đăng ký học phần chính quy',
        'đăng ký học phần tín chỉ',
        'đăng ký học phần tự chọn',
        'đăng ký học phần bắt buộc',
        'đăng ký học phần bổ trợ',
        'đăng ký học phần chuyên ngành',
        'đăng ký học phần chương trình',
        'đăng ký học phần chính quy',
      ],
      'Thành tích SV': [
        'thủ khoa',
        'điểm',
        'chứng chỉ',
        'IELTS',
        'huy chương',
        'Olympic',
        'xuất sắc',
        'đạt',
        'thành tích',
        'vinh danh',
        'giải thưởng',
        'awards',
        'medal',
        'competition',
        'cuộc thi',
        'giải',
        'đạt giải',
        'đạt huy chương',
        'đạt chứng chỉ',
        'ước mơ',
        'nữ sinh viên',
        'sinh viên',
        'Artificial Intelligence Awards',
        'Gold medal',
        'National Student Math Competition',
        'Information and Technology - Communication Awards',
        'Prizes'
      ],
      'Hoạt động SV': [
        'hoạt động',
        'club',
        'đoàn',
        'đội',
        'team',
        'group',
        'câu lạc bộ',
        'đội tình nguyện',
        'đội thi',
        'đội hình',
        'đội ngũ',
        'đội bóng',
        'đội tuyển',
        'đội chơi',
        'đội học',
        'đội thể thao',
        'đội văn nghệ',
        'đội học thuật',
        'đội nghiên cứu',
        'đội học tập',
        'đội học vụ',
        'đội học phần',
        'đội học chuyên ngành',
        'đội học chương trình',
        'đội học chính quy',
        'đội học tín chỉ',
        'đội học phần tự chọn',
        'đội học phần bắt buộc',
        'đội học phần bổ trợ',
        'đội học phần chuyên ngành',
        'đội học phần chương trình',
        'đội học phần chính quy',
        'đội học phần tín chỉ',
        'đội học phần tự chọn',
        'đội học phần bắt buộc',
        'đội học phần bổ trợ',
        'đội học phần chuyên ngành',
        'đội học phần chương trình',
        'đội học phần chính quy',
        'đội học phần tín chỉ',
        'đội học phần tự chọn',
        'đội học phần bắt buộc',
        'đội học phần bổ trợ',
        'đội học phần chuyên ngành',
      ],
      'KH & CN': [
        'nghiên cứu khoa học',
        'NCKH',
        'đề tài',
        'seminar',
        'hội thảo',
        'phát triển ứng dụng',
        'AI',
        'trí tuệ nhân tạo',
        'công nghệ',
        'khoa học',
        'ứng dụng',
        'năng lực ngoại ngữ',
        'năng lực số',
        'seminar',
        'nghiên cứu khoa học',
        'phát triển ứng dụng',
        'AI',
        'trí tuệ nhân tạo',
        'đề tài NCKH',
        'học viên cao học'
      ]
    };

    String tag = "";

    // Quét title và thêm tag tương ứng
    keywordTags.forEach((key, value) {
      for (var keyword in value) {
      if (title.toLowerCase().contains(keyword.toLowerCase())) {
        tag = key;
        return;
      }
      }
    });

    if (tag == "") {
      tag = 'Khác';
    }
    return tag;
  }
}
