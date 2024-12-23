import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final bool isLoggedIn;
  final Function toggleTheme;
  final Function showLoginScreen;
  final Future<void> Function() logout;

  const SettingsScreen({
    required this.isLoggedIn,
    required this.toggleTheme,
    required this.showLoginScreen,
    required this.logout,
    Key? key,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('SettingsScreen: didUpdateWidget');
    print('isLoggedIn: ${widget.isLoggedIn}');
    if (widget.isLoggedIn != oldWidget.isLoggedIn) {
      if (widget.isLoggedIn) {
        // Load username on login
        _loadUsername();
      } else {
        // Clear username on logout
        setState(() {
          username = null;
        });
      }
    }
  }

  Future<void> _loadUsername() async {
    if (widget.isLoggedIn) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final loadedUsername = prefs.getString('moodleUsername') ?? 'Guest';
      setState(() {
        username = loadedUsername; // Update state with loaded username
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text('Dark Mode'),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) => widget.toggleTheme(),
              ),
            ),
            Divider(),
            if (widget.isLoggedIn && username != null) ...[
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Logged in as:'),
                subtitle: Text(username!),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async {
                  await widget.logout();
                  setState(() {
                    username = null; // Clear username on logout
                  });
                },
              ),
            ] else
              ListTile(
                leading: Icon(Icons.login),
                title: Text('Login'),
                onTap: () => widget.showLoginScreen(),
              ),
          ],
        ),
      ),
    );
  }
}
