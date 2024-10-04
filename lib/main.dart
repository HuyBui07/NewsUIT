import 'package:flutter/material.dart';
import 'package:news_uit/apiController/deadlineFetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/deadline_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/testscreen.dart';
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
    DeadlineScreen(),
    Screen2(),
    Screen3(),
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
      title: 'Bottom Navigation Example',
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.menu),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // Logic to open search screen
              },
            ),
          ],
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
