import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../dashboard/evisitor_pass_screen.dart';
import '../../dashboard/grievance/complaint_screen.dart';
import '../../models/visitor_model.dart';
import '../registration/visitor_register_screen.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<Map<String, dynamic>> messages = [];
  TextEditingController _controller = TextEditingController();
  bool voiceEnabled = true;
  String userName = ''; // Stores name after asking
  bool askedForName = true; // First question control

  final visitor = VisitorModel(
    visitorName: 'Shyam Roy',
    fatherName: 'Ram Roy',
    address: '5th Block, Pune',
    gender: 'Male',
    age: 29,
    relation: 'Wife',
    idProof: 'Voter ID',
    idNumber: 'VOT1234567',
    isInternational: false,
    state: 'Maharashtra',
    jail: 'Yerwada Jail',
    visitDate: DateTime.now().add(Duration(days: 3)),
    additionalVisitors: 0,
    additionalVisitorNames: [],
    prisonerName: 'Sunil Gupta',
    prisonerFatherName: 'Vinod Gupta',
    prisonerAge: 35,
    prisonerGender: 'Male',
    mode: false,
    status: VisitStatus.rejected,
    startTime: '14:00',
    endTime: '16:30',
    dayOfWeek: 'Friday',
  );


  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"from": "user", "text": text});
      _botReply(text);
    });

    _controller.clear();
  }

  void _botReply(String userInput) {
    setState(() {
      if (askedForName) {
        messages.add({
          "from": "bot",
          "text": "Hello! What's your name?",
        });
        askedForName = false;
        return;
      }

      if (userName.isEmpty) {
        // Save name from user
        userName = userInput.trim();
        messages.add({
          "from": "bot",
          "text": "Namaste, $userName! I'm your KaraSahayak. How can I help you today?",
          "quickReplies": [
            "REGISTER A VISITOR",
            "REGISTER A GRIEVANCE",
            "SHOW EVISITORPASS",
            "SHOW GOOGLE MAP",
            "EXIT APP"
          ]
        });
        return;
      }

      // User clicked a quick reply or typed matching phrase
      final input = userInput.toLowerCase();

      if (input.contains("register a visitor")) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VisitorFormScreen()),
        ).then((_) {
          messages.add({
            "from": "bot",
            "text": "Welcome back $userName! How can I help you again? Press on menu option to get help",
            "quickReplies": [
              "REGISTER A VISITOR",
              "REGISTER A GRIEVANCE",
              "SHOW EVISITORPASS",
              "SHOW GOOGLE MAP",
              "EXIT APP"
            ]
          });
        });
        return;
      }

      if (input.contains("register a grievance")) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ComplaintScreen()),
        ).then((_) {
          messages.add({
            "from": "bot",
            "text": "Welcome back $userName! How can I help you again? Press on menu option to get help",
            "quickReplies": [
              "REGISTER A VISITOR",
              "REGISTER A GRIEVANCE",
              "SHOW EVISITORPASS",
              "SHOW GOOGLE MAP",
              "EXIT APP"
            ]
          });
        });
        return;
      }

      if (input.contains("show evisitorpass")) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => eVisitorPassScreen(visitor: visitor)),
        ).then((_) {
          messages.add({
            "from": "bot",
            "text": "Welcome back $userName! How can I help you again? Choose from menu option to get help",
            "quickReplies": [
              "REGISTER A VISITOR",
              "REGISTER A GRIEVANCE",
              "SHOW EVISITORPASS",
              "SHOW GOOGLE MAP",
              "EXIT APP"
            ]
          });
        });
        return;
      }

      if (input.contains("show google map")) {
        // Open map URL
        launchUrl(Uri.parse("https://www.google.com/maps/place/NutanTek+Solutions+LLP/@19.7251636,60.9691764,4z/data=!3m1!4b1!4m6!3m5!1s0x390ce5db65f6af0f:0xb29ad5bc8aabd76a!8m2!3d21.0680074!4d82.7525294!16s%2Fg%2F11k6fbjb7n?authuser=0&entry=ttu&g_ep=EgoyMDI1MDcxMy4wIKXMDSoASAFQAw%3D%3D"));
        messages.add({
          "from": "bot",
          "text": "Welcome back $userName! How can I help you again? Choose from menu option to get help",
          "quickReplies": [
            "REGISTER A VISITOR",
            "REGISTER A GRIEVANCE",
            "SHOW EVISITORPASS",
            "SHOW GOOGLE MAP",
            "EXIT APP"
          ]
        });
        return;
      }

      if (input.contains("exit app")) {
        SystemNavigator.pop(); // Closes the app
        return;
      }

      // If user types something irrelevant
      messages.add({
        "from": "bot",
        "text": "Please use the buttons or microphone to continue"
      });
    });
  }


  void _handleQuickReply(String text) {
    _sendMessage(text);
  }

  void _clearChat() {
    setState(() {
      messages.clear();
    });
  }

  void _refreshChat() {
    setState(() {
      messages.clear();
      _botReply("hello"); // reset with greeting
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message["from"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.pink[200] : Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message["text"] ?? ""),
            if (message["quickReplies"] != null)
              Column(
                children: (message["quickReplies"] as List<String>).map((reply) {
                  return Container(
                    margin: EdgeInsets.only(top: 8),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _handleQuickReply(reply),
                      child: Text(reply, style: TextStyle(color: Colors.white)),
                    ),
                  );
                }).toList(),
              )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _botReply("hello"); // Default welcome message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton( // X (Cancel)
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Visitor Registration'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert), // 3 dot menu
            onSelected: (value) {
              if (value == 'toggle_voice') {
                setState(() {
                  voiceEnabled = !voiceEnabled;
                });
              } else if (value == 'clear') {
                _clearChat();
              } else if (value == 'refresh') {
                _refreshChat();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_voice',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Voice'),
                    Switch(
                      value: voiceEnabled,
                      onChanged: (val) {
                        Navigator.pop(context); // Close popup first
                        setState(() {
                          voiceEnabled = val;
                        });
                      },
                    )
                  ],
                ),
              ),
              PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
              PopupMenuItem(value: 'refresh', child: Text('Refresh Chat')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(messages[index]);
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.mic, color: Colors.black), // Voice mic icon
                SizedBox(width: 13),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type here...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF5A8BBA)),
                  onPressed: () => _sendMessage(_controller.text),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
