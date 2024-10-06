import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

// Light & Dark Mode color configurations (already provided by you)
import '../ui_config.dart';

//Used in x-api-key header
const String APIKey = '';

class ChatWithPDF extends StatefulWidget {
  @override
  _ChatWithPDFState createState() => _ChatWithPDFState();
}

class _ChatWithPDFState extends State<ChatWithPDF> {
  String? selectedDocument;
  String sourceId = "";
  String? pdfPath;
  List<Map<String, dynamic>> chatMessages = [];
  int? currentPage;
  bool isSending = false; // Indicates if a message is being sent
  bool isBotTyping = false; // Indicates if the bot is "typing"
  PDFViewController? _pdfViewController;

  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> documents = [
    {
      'title': 'Quy chế đào tạo',
      'sourceId': 'cha_WzNUH7wGY2ifZu853mvoU',
      'pdfPath': 'lib/assets/qcdt.pdf'
    },
    {
      'title': 'Quy trình sinh viên',
      'sourceId': 'cha_bz1VXugmj4qpUq5ONz8hM',
      'pdfPath': 'lib/assets/qtsv.pdf'
    },

    // Add more documents here
  ];

  Future<String> _loadPdfFromAssets(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/temp_pdf.pdf';
      final file = File(tempFilePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (e) {
      print('Error loading PDF: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightModeColors.background,
      body: Column(
        children: [
          // Improved Dropdown for Topic Selection
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: LightModeColors.buttonCommon,
                borderRadius: BorderRadius.circular(10),
                border:
                Border.all(color: LightModeColors.navSelected, width: 1.5),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: DropdownButton<String>(
                  value: selectedDocument,
                  hint: Text('Select a topic',
                      style: TextStyle(color: LightModeColors.navTextAndIcon)),
                  isExpanded: true,
                  underline: Container(),
                  icon: Icon(Icons.arrow_drop_down,
                      color: LightModeColors.navTextAndIcon),
                  items: documents.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc['sourceId'],
                      child: Text(doc['title']!,
                          style:
                          TextStyle(color: LightModeColors.navTextAndIcon)),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    setState(() {
                      selectedDocument = value;
                      sourceId = value!;
                    });
                    String assetPath = documents.firstWhere(
                            (doc) => doc['sourceId'] == value)['pdfPath']!;
                    String pdfFilePath = await _loadPdfFromAssets(assetPath);
                    setState(() {
                      pdfPath = pdfFilePath;
                    });
                  },
                ),
              ),
            ),
          ),

          // PDF Viewer Section
          Expanded(
            child: Stack(
              children: [
                pdfPath != null
                    ? PDFView(
                  enableSwipe: true,
                  filePath: pdfPath,
                  onRender: (pages) {
                    setState(() {});
                  },
                  onViewCreated: (controller) {
                    _pdfViewController = controller;
                  },
                  onPageChanged: (page, total) {
                    setState(() {
                      currentPage = page;
                    });
                  },
                )
                    : Center(
                    child: Text("Select a topic you want to ask about!",
                        style: TextStyle(
                            color: LightModeColors.navTextAndIcon))),

                // Divider to separate PDF and Chat Section
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 8.0,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: LightModeColors.divider,
                          spreadRadius: 0.5,
                          blurRadius: 10,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (currentPage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Page: ${currentPage! + 1}',
                  style: TextStyle(color: LightModeColors.navTextAndIcon)),
            ),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                bool isUser = message['role'] == 'user';
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: LightModeColors.chatBubbleBackgroundBlueish,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft:
                        isUser ? Radius.circular(12) : Radius.circular(0),
                        bottomRight:
                        isUser ? Radius.circular(0) : Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message['content'],
                            softWrap: true,
                            style: TextStyle(
                                color: LightModeColors.chatBubbleTextBlueish)),
                        if (message['references'] != null)
                          Wrap(
                            children: message['references'].map<Widget>((ref) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _scrollToPage(ref['pageNumber']);
                                  },
                                  child: Text(
                                    '[P${ref['pageNumber']}]',
                                    style: const TextStyle(
                                        color: LightModeColors.referenceText,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Sending Message Loading Indicator
          if (isBotTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text("Assistant looking through the document...",
                      style: TextStyle(color: LightModeColors.navTextAndIcon)),
                ],
              ),
            ),

          // Input Field & Send Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: selectedDocument == null
                          ? "Select a topic first"
                          : "Ask a question...",
                      enabled: selectedDocument != null,
                      fillColor: LightModeColors.navBackground,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: isSending
                      ? CircularProgressIndicator()
                      : Icon(Icons.send),
                  onPressed: selectedDocument == null
                      ? null
                      : () async {
                    setState(() {
                      isSending = true;
                    });
                    await _sendMessage(_controller.text);
                    setState(() {
                      isSending = false;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String content) async {
    if (sourceId.isEmpty) return;

    const url = 'https://api.chatpdf.com/v1/chats/message';
    setState(() {
      chatMessages.add({'role': 'user', 'content': content});
      isBotTyping = true;
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': APIKey,
      },
      body: jsonEncode({
        'sourceId': sourceId,
        'messages': [
          ...chatMessages,
          {'role': 'user', 'content': content},
        ],
        'referenceSources': true,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        chatMessages.add({
          'role': 'assistant',
          'content': jsonResponse['content'],
          'references': jsonResponse['references'],
        });
        if (jsonResponse.containsKey('references') &&
            jsonResponse['references'].isNotEmpty) {
          _scrollToPage(jsonResponse['references'][0]['pageNumber']);
        }
        isBotTyping = false;
      });
    } else {
      print('Error: ${response.body}');
      setState(() {
        isBotTyping = false;
      });
    }
    //Clear the input field after sending the message
    _controller.clear();
  }

  void _scrollToPage(int page) {
    if (_pdfViewController != null) {
      _pdfViewController!.setPage(page - 1);
    } else {
      print('PDFViewController not initialized');
    }
  }
}
