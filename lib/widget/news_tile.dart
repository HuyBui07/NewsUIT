import 'package:flutter/material.dart';

import './news_tag.dart';

class NewsTile extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String publishedAt;

  const NewsTile({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: Image.network(
              imageUrl,
              width: 80.0, // Set a fixed width for the image
              height: 120.0, // Set a fixed height for the image
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50.0, // Adjust the height to fit 2 lines of text
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
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(
                      height: 2.0,
                      width: double.infinity,
                      child: Divider(
                        color: Color(0xffE6E6E6),
                        thickness: 2,
                      )),
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
                  const SizedBox(height: 4.0),
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
        ],
      ),
    );
  }
}
