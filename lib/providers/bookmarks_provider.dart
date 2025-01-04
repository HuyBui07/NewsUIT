import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarksProvider with ChangeNotifier {
  List<Map<String, dynamic>> _bookmarks = [];

  List<Map<String, dynamic>> get bookmarks => _bookmarks;

  BookmarksProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];
    _bookmarks = bookmarks.map((bookmark) {
      Map<String, dynamic> decoded = jsonDecode(bookmark);
      decoded['images'] = List<String>.from(decoded['images'] ?? []);
      decoded['tags'] = List<String>.from(decoded['tags'] ?? []);
      return decoded;
    }).toList();
    notifyListeners();
  }

  Future<void> addBookmark(Map<String, dynamic> bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];
    bookmarks.add(jsonEncode(bookmark));
    await prefs.setStringList('bookmarks', bookmarks);
    _loadBookmarks();
  }

  Future<void> removeBookmark(Map<String, dynamic> bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];
    bookmarks.removeWhere((b) => jsonDecode(b)['title'] == bookmark['title']);
    await prefs.setStringList('bookmarks', bookmarks);
    _loadBookmarks();
  }

  bool isBookmarked(Map<String, dynamic> bookmark) {
    return _bookmarks.any((b) => b['title'] == bookmark['title']);
  }
}