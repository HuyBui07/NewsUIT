import 'package:flutter/material.dart';

class TagBox extends StatelessWidget {
  final IconData icon;
  final String tagTitle;
  final bool isSelected;

  const TagBox(
      {super.key,
      required this.icon,
      required this.tagTitle,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2.0 : 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8.0),
          Text(
            tagTitle,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
