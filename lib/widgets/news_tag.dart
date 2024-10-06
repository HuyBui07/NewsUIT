import 'package:flutter/material.dart';

class NewsTag extends StatelessWidget {
  final String title;

  const NewsTag({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 8),
      ),
    );
  }
}
