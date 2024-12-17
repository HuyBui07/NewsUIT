import 'package:flutter/material.dart';

import 'news_tag.dart';

import '../screens/news_details_screen.dart';
import '../screens/post_details_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NewsTile extends StatefulWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String source;
  final String publishedAt;
  final List<String>? tags;
  final String about;

  const NewsTile({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.tags,
    required this.about,
  });

  @override
  State<NewsTile> createState() => _NewsTileState();
}

class _NewsTileState extends State<NewsTile> {
  bool isRead = false;

  @override
  void initState() {
    super.initState();
    _checkRead();
  }

  void _checkRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> readNews = prefs.getStringList('readNews') ?? [];
    if (readNews.contains(widget.title)) {
      setState(() {
        isRead = true;
      });
    }
  }

  Future<void> _markAsRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? readNews = prefs.getStringList('readNews') ?? [];
    if (!readNews.contains(widget.title)) {
      readNews.add(widget.title);
      await prefs.setStringList('readNews', readNews);
      setState(() {
        isRead = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _markAsRead();
        if (widget.source == 'DAA') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailsScreen(
                title: widget.title,
                publishedAt: widget.publishedAt,
                about: widget.about,
              ),
            ),
          );
        } else if (widget.source == 'Facebook') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailsScreen(
                description: widget.title,
                date: widget.publishedAt,
                imageUrl: widget.imageUrl!,
              ),
            ),
          );
        }
      },
      child: Stack(children: [
        if (!isRead)
          Positioned(
            top: 0.0,
            right: 10.0,
            child: Container(
              width: 7.0,
              height: 7.0,
              decoration: const BoxDecoration(
                color: Colors.blue, // Red dot if not read
                shape: BoxShape.circle,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            if (widget.imageUrl != null) ...[
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(24.0), // Set the border radius
                child: Image.network(
                  widget.imageUrl!, // Replace with your image URL
                  width: 80.0, // Set the width of the image
                  height: 120.0, // Set the height of the image
                  fit: BoxFit.cover, // Adjust the image to cover the box
                ),
              ),
              const SizedBox(width: 8.0),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      // Adjust the height to fit 2 lines of text
                      child: Text(
                        widget.title,
                        maxLines: 2, // Limit the title to 2 lines
                        overflow: TextOverflow
                            .ellipsis, // Handle overflow with ellipsis
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    if (widget.description.isNotEmpty) ...[
                      Text(
                        widget.description,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                    const SizedBox(
                        height: 2.0,
                        width: double.infinity,
                        child: Divider(
                          color: Color(0xffE6E6E6),
                          thickness: 2,
                        )),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.grey,
                          size: 14.0,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          widget.publishedAt,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: List.generate(widget.tags?.length ?? 0, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: NewsTag(title: widget.tags![index]),
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
