import 'package:flutter/material.dart';

import "../constants.dart";

// Widgets
import "../widgets/tag_box.dart";
import '../widgets/news_tile.dart';

// APIS
import '../apiControllers/news_fetch_api.dart';
import '../apiControllers/fb_posts_fetch_api.dart';

// Define the global variable
List<Map<String, dynamic>> newItems = [];

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<DropdownMenuEntry<String>> dropDownMenuEntries =
      dropDownMenuSourceOptions
          .map((String option) => DropdownMenuEntry<String>(
                value: option,
                label: option,
              ))
          .toList();

  String _selectedSource = dropDownMenuSourceOptions[0];

  final tagItems = [
    {
      'icon': Icons.star,
      'tagTitle': 'Học vụ',
    },
    {
      'icon': Icons.new_releases,
      'tagTitle': 'Tuyển dụng',
    },
    {
      'icon': Icons.star,
      'tagTitle': 'Thông báo',
    }
  ];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  void fetchNews() async {
    if (newItems.isNotEmpty) {
      return;
    }
    var news = await NewsService.fetchNews();

    setState(() {
      newItems = news.map((news) {
        return {
          'title': news.title,
          'description': news.body,
          'source': 'DAA',
          'publishedAt': news.publishedAt,
          'about': news.about
        };
      }).toList();
    });
  }

  void fetchPosts() async {
    if (newItems.isNotEmpty) {
      return;
    }
    var posts = await PostsService.fetchFanPagePosts();

    setState(() {
      newItems = posts.map((post) {
        return {
          'title': post.description,
          'description': '',
          'source': 'Facebook',
          'publishedAt': post.createdTime,
          'imageUrl': post.fullPicture,
          'about': 'No about'
        };
      }).toList();
    });
  }

  void onSourceChange(String value) async {
    setState(() => _selectedSource = value);
    newItems = [];

    switch (value) {
      case 'DAA':
        fetchNews();
        break;
      case 'CNPM - se.uit.edu.vn':
        fetchPosts();
        break;
      case 'Sự kiện':
        fetchNews();
        break;
      case 'Thông báo':
        fetchNews();
        break;
      default:
        fetchNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 40.0,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              const SizedBox(
                width: 16,
              ),
              ...tagItems.map((item) => TagBox(
                    icon: item['icon'] as IconData,
                    tagTitle: item['tagTitle'] as String,
                  )),
            ]),
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownMenu(
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                ),
                menuStyle: MenuStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                width: double.infinity,
                onSelected: (value) => onSourceChange(value!),
                initialSelection: _selectedSource,
                dropdownMenuEntries: dropDownMenuEntries),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add margin to Divider
            child: Divider(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: newItems.length * 2, // Double the count for dividers
                itemBuilder: (context, index) {
                  if (index.isOdd) {
                    return const FractionallySizedBox(
                      widthFactor: 0.75, // 50% width
                      child: Divider(
                        thickness: 2,
                        color: Color(0xFF87CEEB), // Adjust thickness as needed
                      ),
                    );
                  }
                  final itemIndex = index ~/ 2;
                  final item = newItems[itemIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: NewsTile(
                      title: item['title'] as String,
                      description: item['description'] as String ?? '',
                      imageUrl: item['imageUrl'] ,
                      source: item['source'] as String,
                      publishedAt: item['publishedAt'] as String,
                      about: item['about'] as String,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
