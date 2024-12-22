import 'dart:io';

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool isLoggedIn;
  final Function toggleTheme;
  final Function showLoginScreen;

  const SettingsScreen({
    required this.isLoggedIn,
    required this.toggleTheme,
    required this.showLoginScreen,
    Key? key,
  }) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            if (!widget.isLoggedIn)
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
