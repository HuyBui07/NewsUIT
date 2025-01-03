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
      'icon': Icons.menu_book,
      'tagTitle': 'Học vụ',
    },
    {
      'icon': Icons.work,
      'tagTitle': 'Tuyển dụng',
    },
    {
      'icon': Icons.new_releases,
      'tagTitle': 'Thông báo',
    },
    {
      'icon': Icons.event,
      'tagTitle': 'Sự kiện',
    },
    {'icon': Icons.star, 'tagTitle': 'Khác'}
  ];

  List<Map<String, dynamic>> normalTagItems = [
    {
      'icon': Icons.star,
      'tagTitle': 'Tất cả',
    },
    {
      'icon': Icons.menu_book,
      'tagTitle': 'Học vụ',
    },
    {
      'icon': Icons.work,
      'tagTitle': 'Tuyển dụng',
    },
    {
      'icon': Icons.new_releases,
      'tagTitle': 'Thông báo',
    },
    {
      'icon': Icons.event,
      'tagTitle': 'Sự kiện',
    },
    {'icon': Icons.star, 'tagTitle': 'Khác'}
  ];

  List<Map<String, dynamic>> newsUITTagItems = [
    {
      'icon': Icons.star,
      'tagTitle': 'Tất cả',
    },
    {
      'icon': Icons.menu_book,
      'tagTitle': 'Học vụ',
    },
    {
      'icon': Icons.work,
      'tagTitle': 'Tuyển dụng',
    },
    {
      'icon': Icons.code,
      'tagTitle': 'KH & CN',
    },
    {
      'icon': Icons.event,
      'tagTitle': 'Sự kiện',
    },
    {
      'icon': Icons.emoji_events,
      'tagTitle': 'Thành tích SV',
    },
    {
      'icon': Icons.directions_run,
      'tagTitle': 'Hoạt động SV',
    },
    {'icon': Icons.star, 'tagTitle': 'Khác'}
  ];

  late String filterOption;
  int pageNumber = 0;
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool endOfNews = false;

  @override
  void initState() {
    super.initState();
    filterOption = tagItems[0]['tagTitle'] as String;
    fetchNews();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !endOfNews) {
        pageNumber++;
        setState(() {
          isLoading = true;
        });
        fetchMoreNews();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchMoreNews() async {
    if (_selectedSource == 'DAA') {
      var news = await NewsService.fetchNews(pageNumber);
      if (news.isEmpty) {
        setState(() {
          endOfNews = true;
          isLoading = false;
        });
        return;
      }

      setState(() {
        if (filterOption == 'Tất cả') {
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
        } else {
          newItems.addAll(news
              .where((item) => item.tags.contains(filterOption))
              .map((newsItem) {
            return {
              'title': newsItem.title,
              'description': newsItem.body,
              'source': 'DAA',
              'publishedAt': newsItem.publishedAt,
              'tags': newsItem.tags,
              'about': newsItem.about
            };
          }).toList());
          newItemsBuffer.addAll(news.map((newsItem) {
            return {
              'title': newsItem.title,
              'description': newsItem.body,
              'source': 'DAA',
              'publishedAt': newsItem.publishedAt,
              'tags': newsItem.tags,
              'about': newsItem.about
            };
          }).toList());
        }
      });
    }

    if (_selectedSource == "SeExpress") {
      var morePosts = await PostsService.fetchNextPosts();
      if (morePosts.isEmpty) {
        setState(() {
          endOfNews = true;
          isLoading = false;
        });
        return;
      }

      setState(() {
        if (filterOption == 'Tất cả') {
          newItems.addAll(morePosts.map((post) {
            return {
              'title': post.description,
              'description': '',
              'source': 'Facebook',
              'publishedAt': post.createdTime,
              'images': post.images,
              'video': post.video,
              'about': 'No about',
              'tags': post.tags
            };
          }).toList());
          postItemsBuffer = newItems;
        } else {
          newItems.addAll(morePosts
              .where((item) => item.tags.contains(filterOption))
              .map((post) {
            return {
              'title': post.description,
              'description': '',
              'source': 'Facebook',
              'publishedAt': post.createdTime,
              'images': post.images,
              'video': post.video,
              'about': 'No about',
              'tags': post.tags
            };
          }).toList());
          postItemsBuffer.addAll(morePosts.map((post) {
            return {
              'title': post.description,
              'description': '',
              'source': 'Facebook',
              'publishedAt': post.createdTime,
              'images': post.images,
              'video': post.video,
              'about': 'No about',
              'tags': post.tags
            };
          }).toList());
        }
      });
      return;
    }

    if (_selectedSource == 'SeUIT') {
      var uitNews = await NewsService.fetchUITNews("", pageNumber);

      if (uitNews.isEmpty) {
        setState(() {
          endOfNews = true;
          isLoading = false;
        });
        return;
      }

      setState(() {
        if (filterOption == 'Tất cả') {
          newItems.addAll(uitNews.map((newsItem) {
            return {
              'title': newsItem.title,
              'description': newsItem.body,
              'source': 'SeUIT',
              'publishedAt': newsItem.publishedAt,
              'tags': newsItem.tags,
              'about': newsItem.about
            };
          }).toList());
          newItemsBuffer = newItems;
        } else {
          newItems.addAll(uitNews
              .where((item) => item.tags.contains(filterOption))
              .map((newsItem) {
            return {
              'title': newsItem.title,
              'description': newsItem.body,
              'source': 'SeUIT',
              'publishedAt': newsItem.publishedAt,
              'tags': newsItem.tags,
              'about': newsItem.about
            };
          }).toList());
          newItemsBuffer.addAll(uitNews.map((newsItem) {
            return {
              'title': newsItem.title,
              'description': newsItem.body,
              'source': 'SeUIT',
              'publishedAt': newsItem.publishedAt,
              'tags': newsItem.tags,
              'about': newsItem.about
            };
          }).toList());
        }
      });

      for (var element in newItems) {
        if (element['publishedAt'] == "") {
          String time = await NewsService.fetchUITNewTime(element['about']);
          time = time.replaceFirst("Được đăng: ", "");
          setState(() {
            element['publishedAt'] = time;
          });
        }
      }

      for (var element in newItemsBuffer) {
        if (element['publishedAt'] == "") {
          String time = await NewsService.fetchUITNewTime(element['about']);
          time = time.replaceFirst("Được đăng: ", "");
          setState(() {
            element['publishedAt'] = time;
          });
        }
      }
    }
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
          'images': post.images,
          'video': post.video,
          'about': 'No about',
          'tags': post.tags
        };
      }).toList();
      postItemsBuffer = newItems;
      tagItems = normalTagItems;
    });
  }

  void fetchUITNews() async {
    if (newItems.isNotEmpty) {
      return;
    }

    var uitNews = await NewsService.fetchUITNews("", pageNumber);

    setState(() {
      newItems = uitNews.map((newsItem) {
        return {
          'title': newsItem.title,
          'description': newsItem.body,
          'source': 'SeUIT',
          'publishedAt': newsItem.publishedAt,
          'tags': newsItem.tags,
          'about': newsItem.about
        };
      }).toList();

      tagItems = newsUITTagItems;
    });

    for (var element in newItems) {
      String time = await NewsService.fetchUITNewTime(element['about']);
      time = time.replaceFirst("Được đăng: ", "");
      setState(() {
        element['publishedAt'] = time;
      });
    }
    newItemsBuffer = newItems;
  }

  void onSourceChange(String value) async {
    if (value == _selectedSource) {
      return;
    }
    setState(() {
      _selectedSource = value;
      tagItems = normalTagItems;
    });
    pageNumber = 0;
    newItems = [];
    endOfNews = false;

    switch (value) {
      case 'DAA':
        fetchNews();
        break;
      case 'SeExpress':
        fetchPosts();
        break;
      case 'SeUIT':
        fetchUITNews();
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
        case 'SeUIT':
          filterUITNews(value);
          break;
        default:
          break;
      }
    });
  }

  // filter functions

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

  void filterUITNews(String value) {
    if (value == 'Tất cả') {
      newItems = newItemsBuffer;
      return;
    }
    newItems =
        newItemsBuffer.where((item) => item['tags'].contains(value)).toList();
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
                  if (index == newItems.length * 2) {
                    if (endOfNews) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Đã hết tin tức',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    if (isLoading) {
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
                  }
                  if (index == newItems.length * 2 && !isLoading) {
                    return const SizedBox();
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
