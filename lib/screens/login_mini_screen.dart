import 'dart:io';

import 'package:flutter/material.dart';
import 'package:news_uit/utils/junk.dart';

class PopupLogin extends StatefulWidget {
  final Function afterLogin;

  const PopupLogin({required this.afterLogin, Key? key}) : super(key: key);

  @override
  _PopupLoginState createState() => _PopupLoginState();
}

class _PopupLoginState extends State<PopupLogin> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String _error = '';
  String _successMessage = '';

  Future<bool> loginWithTypedCredentials() async {
    setState(() {
      _loading = true;
      _error = '';
      _successMessage = '';
    });

    bool success = false;

    try {
      // Using LoginSample2 for login logic
      success = await LoginInMoodle(
        _usernameController.text,
        _passwordController.text,
      );
      if (success) {
        setState(() {
          _successMessage = 'Login successful!';
        });
        widget.afterLogin(); // Notify parent widget of successful login
        Navigator.of(context).pop(); // Close the popup
      } else {
        setState(() {
          _error = 'Invalid username or password.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }

    return success;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Login',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            if (_error.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(_error, style: TextStyle(color: Colors.red)),
            ],
            if (_successMessage.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(_successMessage, style: TextStyle(color: Colors.green)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  await loginWithTypedCredentials();
                },
          child: _loading
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text('Login'),
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
