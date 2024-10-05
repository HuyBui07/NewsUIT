import 'package:flutter/material.dart';
import 'package:news_uit/utils/detect_tags.dart';

import "../constants.dart";

// Widgets
import "../widgets/tag_box.dart";
import '../widgets/news_tile.dart';

// APIS
import '../apiControllers/news_fetch_api.dart';

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

  var newItems = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    fetchNews();
    detectTag(
        "Thông báo về việc đào tạo song ngành trình độ đại học hệ chính quy");
  }

  void fetchNews() async {
    var news = await NewsService.fetchNews();
    setState(() {
      newItems = news.map((news) {
        return {
          'title': news.title,
          'description': news.body,
          'imageUrl': 'https://picsum.photos/250?image=9',
          'source': 'Source 1',
          'publishedAt': news.publishedAt,
          'about': news.about
        };
      }).toList();
    });
  }

  void onSourceChange(String value) async {
    setState(() => _selectedSource = value);

    switch (value) {
      case 'DAA':
        fetchNews();
        break;
      case 'CNPM - se.uit.edu.vn':
        fetchNews();
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
        appBar: AppBar(
          title: const Text('News Screen'),
        ),
        body: Column(
          children: [
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
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0), // Add margin to Divider
              child: Divider(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount:
                      newItems.length * 2, // Double the count for dividers
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
                        title: item['title'] as String,
                        description: item['description'] as String,
                        imageUrl: item['imageUrl'] as String,
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
        ));
  }
}
