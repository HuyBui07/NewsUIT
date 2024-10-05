import 'package:flutter/material.dart';
import 'package:news_uit/apiControllers/news_fetch_api.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailsScreen extends StatefulWidget {
  final String title;
  final String publishedAt;
  final String about;

  NewsDetailsScreen({
    required this.title,
    required this.publishedAt,
    required this.about,
  });

  @override
  _NewsDetailsScreenState createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  late Future<String> content;

  @override
  void initState() {
    super.initState();
    print(widget.about);
    content = NewsService.fetchNewsContent(widget.about);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THÔNG BÁO'),
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: content,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    HtmlWidget(
                      snapshot.data!,
                      onTapUrl: (url) async {
                        await launchUrl(Uri.parse(url));

                        return true;
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
