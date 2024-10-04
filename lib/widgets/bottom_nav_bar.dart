// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      //Darker on selected item
      selectedItemColor: Color(0xFF312D3B),
      unselectedItemColor: Color(0xFF4A4459),
      items: const [
        BottomNavigationBarItem(

          icon: Icon(Icons.announcement_outlined, color: Color(0xFF4A4459)),
          label: 'News',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.question_answer_outlined, color: Color(0xFF4A4459)),
          label: 'Helper',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications, color: Color(0xFF4A4459)),
          label: 'Deadline',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, color: Color(0xFF4A4459)),
          label: 'Settings',
        ),
      ],
    );
  }
}
