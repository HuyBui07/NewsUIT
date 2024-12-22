import 'package:flutter/material.dart';

import 'news_tag.dart';

import '../screens/news_details_screen.dart';
import '../screens/post_details_screen.dart';

class NewsTile extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String source;
  final String publishedAt;
  final String about;

  NewsTile({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.about,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (source == 'DAA') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailsScreen(
                title: title,
                publishedAt: publishedAt,
                about: about,
              ),
            ),
          );
        } else if (source == 'Facebook') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailsScreen(
                description: title,
                date: publishedAt,
                imageUrl: imageUrl!,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(24.0), // Set the border radius
              child: Image.network(
                imageUrl!, // Replace with your image URL
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
                      title,
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
                  if (description.isNotEmpty) ...[
                    Text(
                      description,
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
                        publishedAt,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Row(
                    children: [
                      SizedBox(width: 4.0),
                      NewsTag(title: 'Học vụ'),
                      SizedBox(width: 4.0),
                      NewsTag(title: 'Tuyển dụng'),
                      SizedBox(width: 4.0),
                      NewsTag(title: 'Thông báo'),
                      SizedBox(width: 4.0),
                    ],
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
