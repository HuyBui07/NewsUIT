import 'package:flutter/material.dart';
import 'package:news_uit/apiControllers/deadlineFetch.dart';
import 'package:news_uit/screens/helper_screen.dart';
import 'package:news_uit/screens/news_screen.dart';
import 'screens/deadline_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'screens/login_mini_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:news_uit/providers/bookmarks_provider.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MaterialApp(
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
  bool _isLoggedIn = DeadlineService().isLoggedIn;
  int _bookmarksCount = 0;

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
          afterLogin: () async {
            print('Logged in. Setting state to true');
            setState(() {
              _isLoggedIn = true;
            });
            print('Logged state: $_isLoggedIn');
          },
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBookmarks();
  }

  Future<void> fetchBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      _bookmarksCount = bookmarks.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const NewsScreen(),
      const ChatWithPDF(),
      const DeadlineScreen(),
      SettingsScreen(
        isLoggedIn: _isLoggedIn,
        toggleTheme: _toggleTheme,
        showLoginScreen: _showLoginScreen,
        logout: () async {
          await DeadlineService().logout();
          setState(() {
            _isLoggedIn = false;
          });
        },
      ),
    ];

    return ChangeNotifierProvider(
      create: (context) => BookmarksProvider(),
      child: MaterialApp(
        title: 'UITils',
        debugShowCheckedModeBanner: false,
        theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        navigatorObservers: <NavigatorObserver>[routeObserver],
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'UITils',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blue,
            centerTitle: true,
            actions: [
              Consumer<BookmarksProvider>(
                builder: (context, bookmarksProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.collections_bookmark),
                          iconSize: 30,
                          color: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookmarksScreen(),
                              ),
                            );
                          },
                        ),
                        if (bookmarksProvider.bookmarks.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1.0),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${bookmarksProvider.bookmarks.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body:
              screens[_currentIndex], // Use the dynamically built list of screens
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}
