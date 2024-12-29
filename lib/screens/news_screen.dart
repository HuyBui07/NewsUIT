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
List<Map<String, dynamic>> newItemsBuffer = [];
List<Map<String, dynamic>> postItemsBuffer = [];

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

  List<Map<String, dynamic>> tagItems = [
    {
      'icon': Icons.star,
      'tagTitle': 'Tất cả',
    },
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
    },
    {
      'icon': Icons.star,
      'tagTitle': 'Sự kiện',
    },
    {'icon': Icons.star, 'tagTitle': 'Khác'}
  ];


  late String filterOption;
  int pageNumber = 0;
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    filterOption = tagItems[0]['tagTitle'] as String;
    fetchNews();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_selectedSource == 'SeExpress') {
          return;
        }
        pageNumber++;
        isLoading = true;
        fetchMoreNews();
      } else {
        isLoading = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchNews() async {
    if (newItems.isNotEmpty) {
      return;
    }
    var news = await NewsService.fetchNews(pageNumber);

    setState(() {
      newItems = news.map((newsItem) {
        return {
          'title': newsItem.title,
          'description': newsItem.body,
          'source': 'DAA',
          'publishedAt': newsItem.publishedAt,
          'tags': newsItem.tags,
          'about': newsItem.about
        };
      }).toList();
      newItemsBuffer = newItems;
    });
  }

  void fetchMoreNews() async {
    if (_selectedSource != 'DAA') {
      return;
    }

    var news = await NewsService.fetchNews(pageNumber);

    setState(() {
      newItems.addAll(news.map((newsItem) {
        return {
          'title': newsItem.title,
          'description': newsItem.body,
          'source': 'DAA',
          'publishedAt': newsItem.publishedAt,
          'tags': newsItem.tags,
          'about': newsItem.about
        };
      }).toList());
      newItemsBuffer = newItems;
    });
  }

  void fetchPosts() async {
    if (newItems.isNotEmpty) {
      return;
    }
    var posts = await PostsService.fetchFanPagePosts();

    setState(() {
      pageNumber = 0;
      newItems = posts.map((post) {
        return {
          'title': post.description,
          'description': '',
          'source': 'Facebook',
          'publishedAt': post.createdTime,
          'images': post.images,
          'about': 'No about',
          'tags': post.tags
        };
      }).toList();
      postItemsBuffer = newItems;
    });
  }

  void onSourceChange(String value) async {
    setState(() => _selectedSource = value);
    newItems = [];

    switch (value) {
      case 'DAA':
        fetchNews();
        break;
      case 'SeExpress':
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

  // Filter implementation
  String selectedTag = 'Tất cả';

  void onTagChange(String value) {
    setState(() {
      filterOption = value;
      switch (_selectedSource) {
        case 'DAA':
          filterNews(value);
          break;
        case 'SeExpress':
          filterPosts(value);
          break;
        default:
          filterNews(value);
      }
    });
  }

  void filterNews(String value) {
    if (value == 'Tất cả') {
      newItems = newItemsBuffer;
      return;
    }
    newItems =
        newItemsBuffer.where((item) => item['tags'].contains(value)).toList();
  }

  void filterPosts(String value) {
    if (value == 'Tất cả') {
      newItems = postItemsBuffer;
      return;
    }
    newItems =
        postItemsBuffer.where((item) => item['tags'].contains(value)).toList();
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
              ...tagItems.map((item) => GestureDetector(
                    onTap: () => onTagChange(item['tagTitle'] as String),
                    child: TagBox(
                      icon: item['icon'] as IconData,
                      tagTitle: item['tagTitle'] as String,
                      isSelected: filterOption == item['tagTitle'],
                    ),
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
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                itemCount: newItems.length * 2 +
                    1, // Double the count for dividers and 1 for loading
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
                  if (index == newItems.length * 2 && isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == newItems.length * 2 && !isLoading) {
                    return const SizedBox();
                  }
                  final itemIndex = index ~/ 2;
                  final item = newItems[itemIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: NewsTile(
                      title: item['title'] as String,
                      description: item['description'] as String ?? '',
                      images: item['images'],
                      source: item['source'] as String,
                      publishedAt: item['publishedAt'] as String,
                      tags: item['tags'],
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
