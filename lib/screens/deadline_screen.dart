import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ui_config.dart';
import '../apiControllers/deadlineFetch.dart';
import '../utils/utils.dart';
import '../widgets/deadline_item.dart';

class DeadlineScreen extends StatefulWidget {
  @override
  State<DeadlineScreen> createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;
  bool isLoggedIn = DeadlineService().isLoggedIn;
  bool isFetching = false;
  List<DeadlineItemData> deadlinesThisMonth = [];
  List<DeadlineItemData> filteredDeadlines =
      []; // New list for filtered results
  TextEditingController searchController =
      TextEditingController(); // Search controller

  // New state variables for sorting and status filter
  String selectedSortOption = 'Date';
  bool checkForSubmitStatus = false;

  @override
  void initState() {
    super.initState();
    loadPreferences(); // Load stored sort options and filters
    if (isLoggedIn) {
      onDateChange(); // Fetch deadlines for the current month
    }
  }

  // Load stored preferences for sort and filter
  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSortOption = prefs.getString('sortOption') ?? 'Date';
      checkForSubmitStatus = prefs.getBool('filterSubmitted') ?? false;
    });
  }

  // Save preferences for sort and filter
  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sortOption', selectedSortOption);
    prefs.setBool('filterSubmitted', checkForSubmitStatus);
  }

  void onDateChange() async {
    setState(() {
      isFetching = true;
    });

    var deadlineService = DeadlineService();
    var res = await deadlineService.fetchDeadlines(currentMonth,
        checkSubmission: checkForSubmitStatus);

    setState(() {
      isFetching = false;
      deadlinesThisMonth = res.map((deadline) {
        return DeadlineItemData(
          title: deadline['title'],
          classCode: deadline['courseShortName'],
          dueDate:
              DateTime.fromMillisecondsSinceEpoch(deadline['timestamp'] * 1000)
                  .toString(),
          content: deadline['description'],
          url: deadline['url'],
          status: deadline['submitted'],
        );
      }).toList();

      // Update the filtered deadlines list
      filteredDeadlines = deadlinesThisMonth;

      // Optionally, you could sort the deadlines here based on the selectedSortOption
      if (selectedSortOption == 'Date') {
        deadlinesThisMonth.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      } else if (selectedSortOption == 'Status') {
        deadlinesThisMonth.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  // Function to filter deadlines based on the search term
  void filterDeadlines(String searchTerm) {
    setState(() {
      filteredDeadlines = deadlinesThisMonth.where((deadline) {
        return deadline.classCode
                .toLowerCase()
                .contains(searchTerm.toLowerCase()) ||
            deadline.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
            deadline.content.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    });
  }

  void openSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempSortOption = selectedSortOption;
        bool tempFilterSubmitted = checkForSubmitStatus;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          title: const Text(
            'Sort and Filter',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sort by Date or Status
                    ListTile(
                      title: const Text(
                        'Date',
                        style: TextStyle(fontSize: 18),
                      ),
                      leading: Radio<String>(
                        value: 'Date',
                        groupValue: tempSortOption,
                        activeColor:
                            Theme.of(context).primaryColor, // Primary color
                        onChanged: (String? value) {
                          setState(() {
                            tempSortOption = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Status',
                        style: TextStyle(fontSize: 18),
                      ),
                      leading: Radio<String>(
                        value: 'Status',
                        groupValue: tempSortOption,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (String? value) {
                          setState(() {
                            tempSortOption = value!;
                          });
                        },
                      ),
                    ),
                    const Divider(), // Divider for better separation
                    // Checkbox for filtering by submission status
                    CheckboxListTile(
                      title: const Text(
                        'Status check',
                        style: TextStyle(fontSize: 18),
                      ),
                      value: tempFilterSubmitted,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        setState(() {
                          tempFilterSubmitted = value!;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    Theme.of(context).primaryColor, // Text color for the button
              ),
              child: const Text('Apply'),
              onPressed: () {
                setState(() {
                  selectedSortOption = tempSortOption;
                  checkForSubmitStatus = tempFilterSubmitted;
                });
                savePreferences(); // Save the user's preferences
                onDateChange(); // Refresh the deadlines
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    bool loggedIn = DeadlineService().isLoggedIn;

    // Handle date changes (previous or next)
    void dateController(int month, int year, {int op = 0}) {
      setState(() {
        if (op == 0) {
          // Move to the previous month
          if (currentMonth == 1) {
            currentMonth = 12;
            currentYear--;
          } else {
            currentMonth--;
          }
        } else {
          // Move to the next month
          if (currentMonth == 12) {
            currentMonth = 1;
            currentYear++;
          } else {
            currentMonth++;
          }
        }
        onDateChange();
      });
    }

    // Listen to changes in the search text field
    searchController.addListener(() {
      filterDeadlines(searchController.text);
    });

    return Scaffold(
      backgroundColor:
          isDarkMode ? DarkModeColors.background : LightModeColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar and Sort Button
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 50, // Set a fixed height for consistency
                    child: TextField(
                      controller: searchController,
                      // Attach the search controller
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? DarkModeColors.navTextAndIcon
                            : LightModeColors.navTextAndIcon,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        filled: true,
                        fillColor: isDarkMode ? Colors.black : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: isDarkMode
                                ? DarkModeColors.navTextAndIcon
                                : LightModeColors.navTextAndIcon),
                      ),
                      onChanged: (value) {
                        filterDeadlines(
                            value); // Call the filter function on text change
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 50, // Same height as TextField
                    child: ElevatedButton(
                      onPressed: openSortDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? DarkModeColors.buttonCommon
                            : LightModeColors.buttonCommon,
                        side: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Sort & Filter',
                        style: TextStyle(
                          color: isDarkMode
                              ? DarkModeColors.navTextAndIcon
                              : LightModeColors.navTextAndIcon,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Month Selection with Arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: isDarkMode
                      ? DarkModeColors.navTextAndIcon
                      : LightModeColors.navTextAndIcon,
                  onPressed: () {
                    dateController(currentMonth, currentYear, op: 0);
                  },
                ),
                Text(
                  getMonthYearString(currentMonth, currentYear),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? DarkModeColors.commonHeaderText
                        : LightModeColors.commonHeaderText,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  color: isDarkMode
                      ? DarkModeColors.navTextAndIcon
                      : LightModeColors.navTextAndIcon,
                  onPressed: () {
                    dateController(currentMonth, currentYear, op: 1);
                  },
                ),
              ],
            ),
            Divider(
                thickness: 2,
                color: isDarkMode
                    ? DarkModeColors.divider
                    : LightModeColors.divider),

            // List of Deadline Items
            if (!loggedIn)
              Center(
                child: Text(
                  'Please login to view deadlines',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode
                        ? DarkModeColors.commonHeaderText
                        : LightModeColors.commonHeaderText,
                  ),
                ),
              ),
            if (loggedIn)
              isFetching
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: filteredDeadlines.isEmpty
                            ? Center(
                                child: Text(
                                  'No deadlines found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? DarkModeColors.commonHeaderText
                                        : LightModeColors.commonHeaderText,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredDeadlines.length,
                                itemBuilder: (context, index) {
                                  return DeadlineItem(
                                      classCode:
                                          filteredDeadlines[index].classCode,
                                      title: filteredDeadlines[index].title,
                                      dueDate: filteredDeadlines[index].dueDate,
                                      content: filteredDeadlines[index].content,
                                      url: filteredDeadlines[index].url,
                                      isDarkMode: isDarkMode,
                                      status: filteredDeadlines[index].status);
                                },
                              ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}

class DeadlineItemData {
  final String title;
  final String classCode;
  final String status;
  final String dueDate;
  final String content;
  final String url;

  DeadlineItemData({
    required this.title,
    required this.classCode,
    required this.dueDate,
    required this.content,
    required this.url,
    required this.status,
  });
}
