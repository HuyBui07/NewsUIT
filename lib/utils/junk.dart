import 'package:shared_preferences/shared_preferences.dart';

import '../apiController/deadlineFetch.dart';

Future<void> selfCallLoginAndTestDeadline() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final username = "s";
  final password = "a@#";

  // Initialize DeadlineService
  var deadlineService = DeadlineService();

  // Log in and fetch deadlines
  try {
    print("Calling login in DL service");
    final loginSuccess =
        await deadlineService.login(username, password, storeCredentials: true);
    if (loginSuccess) {
      // Fetch deadlines for a specific month (e.g., May = 5)
      print("Calling for deadlines");
      int deadlineMonth = 10;
      final deadlines = await deadlineService.fetchDeadlines(deadlineMonth);

      // Print fetched deadlines
      deadlines.forEach((deadline) {
        print('Course: ${deadline['course-event-name']}');
        print('Title: ${deadline['title']}');
        print(
            'Deadline: ${DateTime.fromMillisecondsSinceEpoch(deadline['timestamp'] * 1000)}');
        print('Description: ${deadline['description']}');
        print('Submitted: ${deadline['submitted']}');
        print('URL: ${deadline['url']}');
        //Add attachment later
        print('----------');
      });
    } else {
      print('[DL Screen] Login failed');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    await deadlineService.logout();
  }
}

Future<bool> LoginSample() async {
  final username = "a";
  final password = "a@#";
  try {
    final loginSuccess = await DeadlineService()
        .login(username, password, storeCredentials: true);
    if (loginSuccess) {
      print('Login successful');
      return true;
    } else {
      print('Login failed');
      return false;
    }
  } catch (e) {
    print('Error: $e');
  }
  return false;
}

Future<bool> LoginSample2(String username, String password) async {
  try {
    final loginSuccess = await DeadlineService()
        .login(username, password, storeCredentials: true);
    if (loginSuccess) {
      print('Login successful');
      return true;
    } else {
      print('Login failed');
      return false;
    }
  } catch (e) {
    print('Error: $e');
  }
  return false;
}
