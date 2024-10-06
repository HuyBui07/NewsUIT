import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailsScreen extends StatelessWidget {
  final String description;
  final String date;
  final String imageUrl;

  PostDetailsScreen({
    required this.description,
    required this.date,
    required this.imageUrl,
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
              Image.network(imageUrl),
            ],
          ),
        ),
      ),
    );
  }
}
