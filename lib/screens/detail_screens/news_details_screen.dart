import 'package:flutter/material.dart';
import 'package:news_uit/apiControllers/news_fetch_api.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:news_uit/providers/bookmarks_provider.dart';

class NewsDetailsScreen extends StatefulWidget {
  final String title;
  final String publishedAt;
  final String about;

  const NewsDetailsScreen({
    super.key,
    required this.title,
    required this.publishedAt,
    required this.about,
  });

  @override
  NewsDetailsScreenState createState() => NewsDetailsScreenState();
}

class NewsDetailsScreenState extends State<NewsDetailsScreen> {
  late Future<String> content;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarked();
    content = NewsService.fetchNewsContent(widget.about);
  }

  Future<void> _checkBookmarked() async {
    Map<String, dynamic> bookmark = {
      'title': widget.title,
      'description': "",
      'source': "DAA",
      'publishedAt': widget.publishedAt,
      'tags': [],
      'about': widget.about,
    };
    final bookmarksProvider =
        Provider.of<BookmarksProvider>(context, listen: false);
    setState(() {
      isBookmarked = bookmarksProvider.isBookmarked(bookmark);
    });
  }

  Future<void> _bookmark() async {
    Map<String, dynamic> bookmark = {
      'title': widget.title,
      'description': "",
      'source': "DAA",
      'publishedAt': widget.publishedAt,
      'tags': [],
      'about': widget.about,
    };
    final bookmarksProvider =
        Provider.of<BookmarksProvider>(context, listen: false);
    if (isBookmarked) {
      await bookmarksProvider.removeBookmark(bookmark);
      setState(() {
        isBookmarked = false;
      });
    } else {
      await bookmarksProvider.addBookmark(bookmark);
      setState(() {
        isBookmarked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('THÔNG BÁO'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: isBookmarked
                ? const Icon(Icons.turned_in)
                : const Icon(Icons.turned_in_not),
            iconSize: 25,
            onPressed: () {
              _bookmark();
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: content,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
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
