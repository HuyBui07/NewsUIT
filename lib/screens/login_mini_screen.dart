import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../utils/junk.dart';
import '../apiController/deadlineFetch.dart';

//Testing login screen, remove later.
class PopupLogin extends StatefulWidget {
  final Function afterLogin;

  PopupLogin({required this.afterLogin});

  @override
  _PopupLoginState createState() => _PopupLoginState();
}

class _PopupLoginState extends State<PopupLogin> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false; // State to show loading
  String _error = ''; // To hold error messages
  String _successMessage = ''; // To hold success message

  @override
  void initState() {
    super.initState();
  }

  Future<bool> login() async {
    setState(() {
      _loading = true; // Start loading
      _error = ''; // Reset error message
      _successMessage = ''; // Reset success message
    });

    bool success = false;

    try {
      // Assume LoginSample returns a boolean indicating success
      success = await LoginSample();
      if (success) {
        setState(() {
          _successMessage = 'Login successful!'; // Display success message
        });
      } else {
        setState(() {
          _error = 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _loading = false; // Stop loading
      });
    }

    return success;
  }

  Future<bool> loginWithTypedCredentials() async {
    setState(() {
      _loading = true; // Start loading
      _error = ''; // Reset error message
      _successMessage = ''; // Reset success message
    });

    bool success = false;

    try {
      // Assume LoginSample2 returns a boolean indicating success
      success = await LoginSample2(
        _usernameController.text,
        _passwordController.text,
      );
      if (success) {
        setState(() {
          _successMessage =
              'Login successful with typed credentials!'; // Display success message
        });
      } else {
        setState(() {
          _error = 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _loading = false; // Stop loading
      });
    }

    return success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator() // Show loading indicator
                : ElevatedButton(
                    onPressed: () async {
                      bool success = await login();
                      if (success) {
                        widget.afterLogin(); // Call after login if successful
                      }
                    },
                    child: Text('Login with set credentials in CODE'),
                  ),
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
            if (_successMessage.isNotEmpty)
              Text(_successMessage, style: TextStyle(color: Colors.green)),
            // Log in with typed credentials
            _loading
                ? CircularProgressIndicator() // Show loading indicator
                : ElevatedButton(
                    onPressed: () async {
                      bool success = await loginWithTypedCredentials();
                      if (success) {
                        widget.afterLogin(); // Call after login if successful
                      }
                    },
                    child: Text('Log in with cred typed'),
                  ),
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
            if (_successMessage.isNotEmpty)
              Text(_successMessage, style: TextStyle(color: Colors.green)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
