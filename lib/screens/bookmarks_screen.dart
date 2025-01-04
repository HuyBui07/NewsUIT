import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:news_uit/widgets/news_tile.dart';
import '../main.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  BookmarksScreenState createState() => BookmarksScreenState();
}

class BookmarksScreenState extends State<BookmarksScreen> with RouteAware {
  List<Map<String, dynamic>> newItems = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unsubscribe from route changes
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    print('BookmarksScreen: user returned using back navigation');
    // Reload bookmarks when navigating back to this screen
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];
      newItems = bookmarks.map((bookmark) {
        Map<String, dynamic> decoded = jsonDecode(bookmark);

        if (decoded['source'] == "Facebook") {
          decoded['images'] = List<String>.from(decoded['images'] ?? []);
          decoded['tags'] = List<String>.from(decoded['tags'] ?? []);
        }

        return decoded;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bookmarks'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: newItems.isEmpty
            ? const Center(
                child: Text('No bookmarks yet'),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: newItems.length * 2,
                  itemBuilder: (context, index) {
                    if (index.isOdd) {
                      return const FractionallySizedBox(
                        widthFactor: 0.75, // 50% width
                        child: Divider(
                          thickness: 2,
                          color:
                              Color(0xFF87CEEB), // Adjust thickness as needed
                        ),
                      );
                    }
                    final itemIndex = index ~/ 2;
                    final item = newItems[itemIndex];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: NewsTile(
                        title: (item['title'] as String),
                        description: item['description'] as String ?? '',
                        images: item['images'],
                        video: item['video'],
                        source: item['source'] as String,
                        publishedAt: item['publishedAt'] as String,
                        tags: const [""],
                        about: item['about'] as String,
                      ),
                    );
                  },
                ),
              ));
  }
}
