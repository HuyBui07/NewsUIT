import 'package:flutter/material.dart';

import "../constants.dart";

// Widgets
import "../widget/tag_box.dart";
import '../widget/news_tile.dart';

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

  final newItems = [
    {
      'title': 'Thông báo tuyển dụng thực tập công ty FPT',
      'description': 'Description 1',
      'imageUrl': 'https://picsum.photos/250?image=9',
      'source': 'Source 1',
      'publishedAt': 'Published At 1',
    },
    {
      'title': 'Title 2',
      'description': 'Description 2',
      'imageUrl': 'https://picsum.photos/250?image=10',
      'source': 'Source 2',
      'publishedAt': 'Published At 2',
    },
    {
      'title': 'Title 3',
      'description': 'Description 3',
      'imageUrl': 'https://picsum.photos/250?image=11',
      'source': 'Source 3',
      'publishedAt': 'Published At 3',
    },
    {
      'title': 'Title 4',
      'description': 'Description 4',
      'imageUrl': 'https://picsum.photos/250?image=12',
      'source': 'Source 4',
      'publishedAt': 'Published At 4',
    },
    {
      'title': 'Title 5',
      'description': 'Description 5',
      'imageUrl': 'https://picsum.photos/250?image=13',
      'source': 'Source 5',
      'publishedAt': 'Published At 5',
    },
    {
      'title': 'Title 6',
      'description': 'Description 6',
      'imageUrl': 'https://picsum.photos/250?image=14',
      'source': 'Source 6',
      'publishedAt': 'Published At 6',
    },
    {
      'title': 'Title 7',
      'description': 'Description 7',
      'imageUrl': 'https://picsum.photos/250?image=15',
      'source': 'Source 7',
      'publishedAt': 'Published At 7',
    },
    {
      'title': 'Title 8',
      'description': 'Description 8',
      'imageUrl': 'https://picsum.photos/250?image=16',
      'source': 'Source 8',
      'publishedAt': 'Published At 8',
    },
  ];

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
                  onSelected: (value) =>
                      setState(() => _selectedSource = value!),
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
                              Color(0xFFE6E6E6), // Adjust thickness as needed
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
