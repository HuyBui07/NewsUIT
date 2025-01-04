import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:news_uit/widgets/VideoPlayerWidget.dart';
import 'package:provider/provider.dart';
import 'package:news_uit/providers/bookmarks_provider.dart';

class PostDetailsScreen extends StatefulWidget {
  final String description;
  final String date;
  final List<String>? images;
  final String? video;

  const PostDetailsScreen({
    super.key,
    required this.description,
    required this.date,
    this.images,
    this.video,
  });

  @override
  PostDetailsScreenState createState() => PostDetailsScreenState();
}

class PostDetailsScreenState extends State<PostDetailsScreen> {
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    checkBookmarked();
  }

  Future<void> checkBookmarked() async {
    final bookmark = {
      'title': widget.description,
      'description': '',
      'source': 'Facebook',
      'publishedAt': widget.date,
      'images': widget.images,
      'video': widget.video,
    };
    final bookmarksProvider =
        Provider.of<BookmarksProvider>(context, listen: false);
    setState(() {
      isBookmarked = bookmarksProvider.isBookmarked(bookmark);
    });
  }

  Future<void> bookmark() async {
    Map<String, dynamic> bookmark = {
      'title': widget.description,
      'description': '',
      'source': 'Facebook',
      'publishedAt': widget.date,
      'images': widget.images,
      'video': widget.video,
      'about': 'No about',
      'tags': [],
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

  // Function to open the URL
  Future<void> _onOpenLink(LinkableElement link) async {
    if (await canLaunchUrl(Uri.parse(link.url))) {
      await launchUrl(Uri.parse(link.url));
    } else {
      throw 'Could not launch ${link.url}';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> mediaItems = [
      if (widget.video != null && widget.video != "")
        VideoPlayerWidget(
          videoUrl: widget.video!,
        ),
      if (widget.images != null && widget.video == "")
        ...widget.images!.map((imageUrl) => Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fitWidth,
                  ),
                );
              },
            )),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('BÀI ĐĂNG'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: isBookmarked
                ? const Icon(Icons.turned_in)
                : const Icon(Icons.turned_in_not),
            iconSize: 30,
            onPressed: () {
              bookmark();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.date,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Linkify(
                  text: widget.description,
                  onOpen: _onOpenLink,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  linkStyle: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  )),
              const SizedBox(height: 16),
              FlutterCarousel(
                options: FlutterCarouselOptions(
                  height: 400.0,
                  enableInfiniteScroll: mediaItems.length > 1,
                  showIndicator: true,
                  slideIndicator: CircularSlideIndicator(
                      slideIndicatorOptions: const SlideIndicatorOptions(
                          indicatorBackgroundColor: Colors.grey,
                          currentIndicatorColor: Colors.black)),
                  viewportFraction: 1.0,
                ),
                items: mediaItems,
              )
            ],
          ),
        ),
      ),
    );
  }
}
