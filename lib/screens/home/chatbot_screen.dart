import 'package:eMulakat/dashboard/visit/visit_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../dashboard/evisitor_pass_screen.dart';
import '../../dashboard/grievance/grievance_home.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';
import '../../models/visitor_model.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<Map<String, dynamic>> messages = [];
  TextEditingController _controller = TextEditingController();
  bool voiceEnabled = false;
  bool askedForName = false;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';
  bool _showVoiceDialog = false;

  String userName = 'Suresh';// First question control

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
    final input = userInput.toLowerCase();

    setState(() {
      // FIRST greeting on app start
      if (messages.isEmpty) {
        messages.add({
          "from": "bot",
          "text": "Hello $userName!"
        });
        return;
      }

      // Greeting response
      if (input.contains("hello") || input.contains("hi") || input.contains("hey")) {
        messages.add({
          "from": "bot",
          "text": "Hey $userName! I'm your KaraSahayak. How can I help you today?",
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

      // Visitor keyword
      if (input.contains("visitor")) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VisitHomeScreen(fromChatbot: true)), // ✅ Pass fromChatbot flag
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

      // Grievance keyword
      if (input.contains("grievance")) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GrievanceHomeScreen(fromChatbot: true)), // ✅ Pass fromChatbot flag
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

      // eVisitorPass
      if (input.contains("evisitor") || input.contains("pass")) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => eVisitorPassScreen(visitor: visitor)),
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

      // Google Map
      if (input.contains("map") || input.contains("google")) {
        launchUrl(Uri.parse("https://www.google.com/maps/place/NutanTek+Solutions+LLP/@19.7251636,60.9691764,4z/data=!3m1!4b1!4m6!3m5!1s0x390ce5db65f6af0f:0xb29ad5bc8aabd76a!8m2!3d21.0680074!4d82.7525294!16s%2Fg%2F11k6fbjb7n?authuser=0&entry=ttu&g_ep=EgoyMDI1MDcxMy4wIKXMDSoASAFQAw%3D%3D"));
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
        return;
      }

      // Exit
      if (input.contains("exit")) {
        SystemNavigator.pop();
        return;
      }

      // If unrecognized
      messages.add({
        "from": "bot",
        "text": "Please try again or type using the keyboard."
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
          color: isUser ? Colors.grey[300] : Colors.blue[100],
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
    _speech = stt.SpeechToText();
    _isListening = false; // Default mic OFF
    _botReply("hello"); // Default welcome message
  }

  void _showVoicePopup() {
    setState(() {
      _showVoiceDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // eMulakat Title
                Text(
                  "eMulakat",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[700],
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 40),

                // Animated Mic Icon with Circles
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing circle
                    AnimatedContainer(
                      duration: Duration(milliseconds: 1000),
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Color(0xFF4285F4).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Middle circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFF4285F4).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Inner blue circle with mic
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Color(0xFF4285F4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // Try saying something text
                Text(
                  "Try saying something",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 30),

                // Cancel Button
                TextButton(
                  onPressed: () {
                    _stopListening();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    _startListening();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        print('Status: $val');
        // When listening stops, process the message
        if (val == 'done' || val == 'notListening') {
          if (_voiceText.isNotEmpty && _isListening) {
            _stopListening();
            Navigator.of(context).pop(); // Close popup
            _sendMessage(_voiceText);
          }
        }
      },
      onError: (val) {
        print('Error: $val');
        _stopListening();
        Navigator.of(context).pop();
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _voiceText = val.recognizedWords;
          });

          // If we have confidence and final result
          if (val.hasConfidenceRating && val.confidence > 0 && _voiceText.isNotEmpty) {
            // Add small delay to capture complete speech
            Future.delayed(Duration(milliseconds: 500), () {
              if (_isListening && _voiceText.isNotEmpty) {
                _stopListening();
                Navigator.of(context).pop(); // Close popup
                _sendMessage(_voiceText);
              }
            });
          }
        },
        listenFor: Duration(seconds: 10), // Auto stop after 10 seconds
        pauseFor: Duration(seconds: 3),   // Stop if pause for 3 seconds
      );
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _showVoiceDialog = false;
    });
    _speech.stop();
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
          title: Text('KaraSahayak'),
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
        body: SafeArea(
          child: Column(
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
                    // Mic Button - Always OFF by default
                    IconButton(
                      icon: Icon(
                        Icons.mic_off, // Always show mic_off
                        color: Colors.black,
                      ),
                      onPressed: _showVoicePopup, // Show popup when clicked
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Type here...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.send, color: Color(0xFF5A8BBA)),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}