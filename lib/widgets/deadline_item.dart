import 'package:flutter/material.dart';
import '../ui_config.dart';
import 'package:google_fonts/google_fonts.dart';

class DeadlineItem extends StatefulWidget {
  final String title;
  final String classCode;
  final String dueDate;
  final bool isDarkMode;
  final String content;
  final String url;
  final String status; // New status parameter

  // Attachment later
  DeadlineItem({
    required this.title,
    required this.classCode,
    required this.dueDate,
    required this.isDarkMode,
    required this.content,
    required this.url,
    required this.status, // Pass status directly
  });

  @override
  State<DeadlineItem> createState() => _DeadlineItemState();
}

class _DeadlineItemState extends State<DeadlineItem> {
  final int ShortTitleLength = 15;
  final int ShortContentLength = 50;

  String shortenContent(String content, int length) {
    if (content.length <= length) {
      return content;
    }
    return content.substring(0, length) + '...';
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // Determine the status color based on the passed status
    Color statusColor;
    if (widget.status == 'Pending') {
      statusColor = widget.isDarkMode
          ? DarkModeColors.deadlinePendingText
          : LightModeColors.deadlinePendingText;
    } else if (widget.status == 'Submitted') {
      statusColor = widget.isDarkMode
          ? DarkModeColors.deadlineSubmittedText
          : LightModeColors.deadlineSubmittedText;
    } else if (widget.status == 'Not checked') {
      statusColor = widget.isDarkMode
          ? DarkModeColors.deadlineNotcheckedText
          : LightModeColors.deadlineNotcheckedText;
    } else {
      statusColor = widget.isDarkMode
          ? DarkModeColors.deadlineOverdueText
          : LightModeColors.deadlineOverdueText;
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: widget.isDarkMode
                  ? DarkModeColors.background
                  : LightModeColors.background,
              titlePadding: EdgeInsets.all(20),
              contentPadding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.title} - ${widget.classCode}',
                    style: GoogleFonts.roboto(
                      color: widget.isDarkMode
                          ? DarkModeColors.commonHeaderText
                          : LightModeColors.commonHeaderText,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Due by ${formatDate(widget.dueDate)}',
                    style: GoogleFonts.roboto(
                      color: widget.isDarkMode
                          ? DarkModeColors.deadlineDueText
                          : LightModeColors.deadlineDueText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: GoogleFonts.roboto(
                          color: widget.isDarkMode
                              ? DarkModeColors.commonFadedText
                              : LightModeColors.commonFadedText,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.status,
                        style: GoogleFonts.roboto(
                          color: statusColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      child: SingleChildScrollView(
                        child: Text(
                          widget.content.isEmpty
                              ? 'No description provided'
                              : widget.content,
                          style: GoogleFonts.roboto(
                            color: widget.isDarkMode
                                ? DarkModeColors.commonFadedText
                                : LightModeColors.commonFadedText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attachments:',
                          style: GoogleFonts.roboto(
                            color: widget.isDarkMode
                                ? DarkModeColors.commonHeaderText
                                : LightModeColors.commonHeaderText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            // Handle file download
                          },
                          child: Text(
                            'File122.pptx',
                            style: GoogleFonts.roboto(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            // Handle file download
                          },
                          child: Text(
                            'File2.sql',
                            style: GoogleFonts.roboto(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actionsPadding: EdgeInsets.all(10),
              actions: [
                TextButton(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? DarkModeColors.commonFadedText
                          : LightModeColors.commonFadedText,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shortenContent(widget.title, ShortTitleLength),
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode
                            ? DarkModeColors.deadlineHeader
                            : LightModeColors.deadlineHeader,
                      ),
                    ),
                    // "-" separator
                    Text(
                      '-',
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode
                            ? DarkModeColors.deadlineHeader
                            : LightModeColors.deadlineHeader,
                      ),
                    ),
                    Text(
                      widget.classCode,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode
                            ? DarkModeColors.deadlineClassHeader
                            : LightModeColors.deadlineClassHeader,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                // Row 2: Shortened content
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.content.isEmpty
                            ? 'No description provided'
                            : shortenContent(
                                widget.content, ShortContentLength),
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 12,
                          color: widget.isDarkMode
                              ? DarkModeColors.deadlineContentText
                              : LightModeColors.deadlineContentText,
                        ),
                        softWrap: true,
                        maxLines: 2,
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 24),
            Column(
              children: [
                // Row 3: Status and Due date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: statusColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          widget.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatDate(widget.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode
                            ? DarkModeColors.deadlineDueText
                            : LightModeColors.deadlineDueText,
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: widget.isDarkMode
                      ? DarkModeColors.divider
                      : LightModeColors.divider,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
