import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import '../ui_config.dart';

const String APIKey = 'sec_pecQb1g21Pk0SvQCSornBoMGlLfZ0sHX';

class ChatWithPDF extends StatefulWidget {
  @override
  _ChatWithPDFState createState() => _ChatWithPDFState();
}

class _ChatWithPDFState extends State<ChatWithPDF>
    with SingleTickerProviderStateMixin {
  String? selectedDocument;
  String sourceId = "";
  String? pdfPath;
  List<Map<String, dynamic>> chatMessages = [];
  int? currentPage;
  bool isSending = false;
  bool isBotTyping = false;
  bool isChatOpen = false;
  PDFViewController? _pdfViewController;

  final TextEditingController _controller = TextEditingController();
  late AnimationController _typingAnimationController;

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
  ];

  @override
  void initState() {
    super.initState();
    _typingAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat();
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: LightModeColors.buttonCommon,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: LightModeColors.navSelected, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    child: DropdownButton<String>(
                      value: selectedDocument,
                      hint: Text('Select a topic',
                          style:
                              TextStyle(color: LightModeColors.navTextAndIcon)),
                      isExpanded: true,
                      underline: Container(),
                      icon: Icon(Icons.arrow_drop_down,
                          color: LightModeColors.navTextAndIcon),
                      items: documents.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc['sourceId'],
                          child: Text(doc['title']!,
                              style: TextStyle(
                                  color: LightModeColors.navTextAndIcon)),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          selectedDocument = value;
                          sourceId = value!;
                          currentPage = null; // Reset current page
                          pdfPath = null; // Reset pdfPath
                        });
                        String assetPath = documents.firstWhere(
                            (doc) => doc['sourceId'] == value)['pdfPath']!;
                        String pdfFilePath =
                            await _loadPdfFromAssets(assetPath);
                        setState(() {
                          pdfPath = pdfFilePath;
                        });
                      },
                    ),
                  ),
                ),
              ),
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
                            child: Text(
                              "Select a topic you want to ask about!",
                              style: TextStyle(
                                  color: LightModeColors.navTextAndIcon),
                            ),
                          ),
                    if (currentPage != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Text('Page: ${currentPage! + 1}',
                            style: TextStyle(
                                color: LightModeColors.navTextAndIcon)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: isChatOpen ? 0 : 30,
            right: isChatOpen ? 0 : 30,
            child: GestureDetector(
              onTap: () {
                if (!isChatOpen) {
                  setState(() {
                    isChatOpen = true;
                  });
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isChatOpen ? MediaQuery.of(context).size.width : 60,
                height:
                    isChatOpen ? MediaQuery.of(context).size.height * 0.6 : 60,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(isChatOpen ? 20 : 30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isChatOpen ? 20 : 30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: isChatOpen
                          ? Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon:
                                        Icon(Icons.close, color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        isChatOpen = false;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: chatMessages.length +
                                        (isBotTyping ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (isBotTyping &&
                                          index == chatMessages.length) {
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 10),
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("Bot is typing... ",
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                AnimatedBuilder(
                                                  animation:
                                                      _typingAnimationController,
                                                  builder: (context, child) {
                                                    return Text(
                                                      "." *
                                                          ((_typingAnimationController
                                                                      .value *
                                                                  3)
                                                              .ceil()),
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      final message = chatMessages[index];
                                      bool isUser = message['role'] == 'user';
                                      return Align(
                                        alignment: isUser
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isUser
                                                ? Colors.blueAccent
                                                    .withOpacity(0.7)
                                                : Colors.white.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message['content'],
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              if (message['references'] !=
                                                      null &&
                                                  message['references']
                                                      .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "References:",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      ...message['references']
                                                          .map<Widget>(
                                                              (reference) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            _scrollToPage(
                                                                reference[
                                                                    'pageNumber']);
                                                          },
                                                          child: Text(
                                                            "- Page ${reference['pageNumber']}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .lightBlueAccent,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _controller,
                                        decoration: InputDecoration(
                                          hintText: selectedDocument == null
                                              ? "Select a topic first"
                                              : "Ask a question...",
                                          enabled: selectedDocument != null,
                                          fillColor:
                                              Colors.white.withOpacity(0.8),
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: isSending
                                          ? CircularProgressIndicator()
                                          : Icon(Icons.send,
                                              color: Colors.white),
                                      onPressed: selectedDocument == null
                                          ? null
                                          : () async {
                                              setState(() {
                                                isSending = true;
                                              });
                                              await _sendMessage(
                                                  _controller.text);
                                              setState(() {
                                                isSending = false;
                                              });
                                            },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Icon(Icons.chat, color: Colors.white),
                    ),
                  ),
                ),
              ),
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
