import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class PostDetailsScreen extends StatelessWidget {
  final String description;
  final String date;
  final List<String> images;

  const PostDetailsScreen({
    super.key,
    required this.description,
    required this.date,
    required this.images,
  });

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('BÀI ĐĂNG'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Linkify(
                  text: description,
                  onOpen: _onOpenLink,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  linkStyle: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  )),
              const SizedBox(height: 16),
              FlutterCarousel(
                options: FlutterCarouselOptions(
                  height: 400.0,
                  enableInfiniteScroll: true,
                  showIndicator: true,
                  slideIndicator: CircularSlideIndicator(),
                  viewportFraction: 1.0,
                ),
                items: images.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
