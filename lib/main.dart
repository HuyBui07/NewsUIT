import 'package:flutter/material.dart';
import 'package:news_uit/screens/helper_screen.dart';
import 'package:news_uit/screens/news_screen.dart';
import 'screens/deadline_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/login_mini_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  // List of Screens to display for each tab
  final List<Widget> _screens = [
    const NewsScreen(),
    ChatWithPDF(),
    DeadlineScreen(),
    PopupLogin(afterLogin: () {}),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UITils',
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
              child: Text('UITils',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
          backgroundColor: Colors.blue,
        ),
        body: _screens[_currentIndex], // Display the current selected screen
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}