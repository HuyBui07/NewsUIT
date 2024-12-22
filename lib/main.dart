import 'package:flutter/material.dart';
import 'package:news_uit/screens/helper_screen.dart';
import 'package:news_uit/screens/news_screen.dart';
import 'screens/deadline_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/login_mini_screen.dart';
import 'screens/setting_screen.dart';

void main() {
  runApp(MaterialApp(
    home: MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  bool _isDarkMode = false;
  bool _isLoggedIn = false;

  // Toggle the theme
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Show login screen
  void _showLoginScreen() {
    showDialog(
      context: context,
      builder: (context) => Builder(
        builder: (dialogContext) => PopupLogin(
          afterLogin: () {
            setState(() {
              _isLoggedIn = true;
            });
          },
        ),
      ),
    );
  }

  // List of Screens to display for each tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const NewsScreen(),
      ChatWithPDF(),
      DeadlineScreen(),
      SettingsScreen(
        isLoggedIn: _isLoggedIn,
        toggleTheme: _toggleTheme,
        showLoginScreen: _showLoginScreen,
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UITils',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Center(
              child: const Text('UITils',
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
