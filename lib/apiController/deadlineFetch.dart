import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:html/parser.dart' as htmlParser;
import 'dart:io';

class DeadlineService {
  static final DeadlineService _instance = DeadlineService._internal();
  static final String baseUrl = 'https://courses.uit.edu.vn';

  static late Dio _dio;
  static late CookieJar _cookieJar;
  static bool _isLoggedIn = false;
  static bool _isInitialized = false;

  DeadlineService._internal() {
    _initialize();
  }

  factory DeadlineService() => _instance;

  // Initialize Dio and the Cookie Manager
  Future<void> _initialize() async {
    _dio = Dio();
    final appDocDir = await getApplicationDocumentsDirectory();
    if (File('${appDocDir.path}/cookies.json').existsSync()) {
      File('${appDocDir.path}/cookies.json').deleteSync();
    }
    _cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));
    /*  _dio.interceptors.add(LogInterceptor(
        responseBody: false, requestBody: false, requestHeader: true));*/
    _isInitialized = true;
  }

  // Ensure the service is initialized before making any requests
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initialize();
    }
  }

  //External method to expose logged in status
  bool get isLoggedIn => _isLoggedIn;

  // Check if the user is logged in by verifying the presence of a specific element in the HTML response
  Future<bool> _checkLoggedInStatus() async {
    final response =
        await _dio.get(baseUrl, options: Options(followRedirects: true));
    final body = response.data;
    return body.contains('id="frontpage-course-list"');
  }

  // Login using username and password
  Future<bool> login(String username, String password,
      {bool storeCredentials = false}) async {
    await _ensureInitialized();

    try {
      final loginPageResponse = await _dio.get('$baseUrl/login/index.php',
          options: Options(followRedirects: false));
      final body = loginPageResponse.data;

      // Extract login token from the login page
      final logintokenRegex = RegExp(r'name="logintoken" value="([^"]+)"');
      final match = logintokenRegex.firstMatch(body);

      if (match == null) {
        print('Already logged in or login token not found');
        _isLoggedIn = true;
        return true;
      }

      final logintoken = match.group(1)!;
      print('Login token: $logintoken');

      // Send login request
      final loginData = {
        'username': username,
        'password': password,
        'logintoken': logintoken,
        'anchor': '',
      };

      //Remember to validate for status and turn off redirect otherwise its just gonna loop for goddamn forever
      var loginResponse = await _dio.post('$baseUrl/login/index.php',
          options: Options(
              contentType: Headers.formUrlEncodedContentType,
              followRedirects: false,
              validateStatus: (status) {
                return status == 200 || status == 303;
              }),
          data: loginData);

      /*// Find the <a> with id "loginerrormessage" then print out
      final loginError = htmlParser
          .parse(loginResponse.data)
          .querySelector("#loginerrormessage");
      if (loginError != null) {
        print("LOGIN ERROR: ${loginError.text}");
      }*/

      _isLoggedIn = await _checkLoggedInStatus();

      if (!_isLoggedIn) {
        print('Login failed');
        return false;
      }

      // Store credentials if requested
      if (storeCredentials) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('moodleUsername', username);
        prefs.setString('moodlePassword', password);
      }

      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Logout by calling the logout URL
  Future<void> logout() async {
    await _ensureInitialized();
    try {
      final sessKey = await _fetchSessionKey();
      if (sessKey != null) {
        print('Logging out for sesskey: $sessKey');
        final logoutResponse =
            await _dio.get('$baseUrl/login/logout.php?sesskey=$sessKey',
                options: Options(
                    followRedirects: false,
                    validateStatus: (status) {
                      return status == 200 || status == 303;
                    }));

        if (logoutResponse.statusCode == 200 ||
            logoutResponse.statusCode == 303) {
          print("Logged out successfully");
        } else {
          print("Failed to log out");
        }
      } else {
        print("Already logged out or session key not found");
      }
    } catch (e) {
      print("Error during logout: $e");
    } finally {
      // Clear stored credentials
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('moodleUsername');
      prefs.remove('moodlePassword');
      _isLoggedIn = false;
    }
  }

  // Fetch deadlines for a given month
  Future<List<Map<String, dynamic>>> fetchDeadlines(int month,
      {bool checkSubmission = false}) async {
    await _ensureInitialized(); // Ensure the service is initialized
    try {
      await _loginFromStoredCredentials(); // Await the login process
      if (!_isLoggedIn) {
        print('Not logged in');
        return [];
      }
      final sessKey = await _fetchSessionKey();
      final currentYear = DateTime.now().year;

      final url =
          '$baseUrl/lib/ajax/service.php?sesskey=$sessKey&info=core_calendar_get_calendar_monthly_view';

      final args = {
        'year': currentYear.toString(),
        'month': month.toString(),
        'day': 1,
        'view': 'monthblock'
      };

      // Make POST request to fetch deadlines
      final response = await _dio.post(
        url,
        options: Options(contentType: Headers.jsonContentType),
        data: jsonEncode([
          {
            'index': 0,
            'methodname': 'core_calendar_get_calendar_monthly_view',
            'args': args,
          }
        ]),
      );

      final data = response.data;
      List<Map<String, dynamic>> deadlines = [];

      data[0]['data']['weeks'].forEach((week) {
        week['days'].forEach((day) {
          day['events'].forEach((event) async {
            final eventUrl = event['url']; // Extract event URL
            String submitted = "Pending";

            // Check submission status only if the flag is true
            // If subCheck is true, always set to submitted.
            // else, if before deadline = Pending
            // else, late
            if (checkSubmission) {
              bool subCheck = await _checkSubmitted(eventUrl);
              if (subCheck) {
                submitted = "Submitted";
              } else {
                DateTime deadline = DateTime.fromMillisecondsSinceEpoch(
                    event['timesort'] * 1000);
                if (DateTime.now().isBefore(deadline)) {
                  submitted = "Pending";
                } else {
                  submitted = "Late";
                }
              }
            }

            deadlines.add({
              'courseShortName': event['course']['shortname'],
              'courseName': event['course']['fullname'],
              'title': event['name'],
              'course-event-name':
                  '${event['course']['shortname']} - ${event['name']}',
              'HtmlDescription': event['description'],
              'description': htmlDescriptionToText(event['description']),
              'timestamp': event['timesort'],
              'submitted': submitted, // Include submitted status
              'year': currentYear,
              'month': month,
              'day': day['mday'],
              'url': eventUrl,
            });
          });
        });
      });

      return deadlines;
    } catch (e) {
      print('Error fetching deadlines: $e');
      return [];
    }
  }

  String htmlDescriptionToText(String htmlDescription) {
    final document = htmlParser.parse(htmlDescription);
    return document.body!.text;
  }

  Future<bool> _checkSubmitted(String eventUrl) async {
    try {
      final response = await _dio.get(eventUrl);
      final document = htmlParser.parse(response.data);

      // Check if the event is a quiz and look for the quiz attempt summary table
      final quizAttemptSummary =
          document.querySelector(".generaltable.quizattemptsummary");
      if (quizAttemptSummary != null) {
        final tableBody = quizAttemptSummary.querySelector("tbody");
        if (tableBody != null && tableBody.children.isNotEmpty) {
          return true; // Submitted
        }
      }

      // Check if the event is an assignment
      final submissionStatus =
          document.querySelector(".submissionstatussubmitted");
      if (submissionStatus != null) {
        return true; // Submitted
      }
    } catch (e) {
      print('Error checking submission: $e');
    }
    return false; // Not submitted
  }

  // Private helper method to fetch the session key from the homepage
  Future<String?> _fetchSessionKey() async {
    try {
      final response = await _dio.get(baseUrl);
      final body = response.data;
      final sesskeyRegex = RegExp(r'"sesskey":"([^"]+)"');
      final match = sesskeyRegex.firstMatch(body);
      return match?.group(1);
    } catch (e) {
      print('Error fetching sesskey: $e');
      return null;
    }
  }

  // Login using stored credentials if available
  Future<void> _loginFromStoredCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('moodleUsername');
    final password = prefs.getString('moodlePassword');
    if (username != null && password != null) {
      await login(username, password);
    }
  }
}
