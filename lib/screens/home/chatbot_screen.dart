import 'package:eMulakat/dashboard/visit/visit_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../dashboard/evisitor_pass_screen.dart';
import '../../dashboard/grievance/grievance_home.dart';
import '../../models/keyword_model.dart';
import '../../models/visitor_model.dart';
import '../../services/api_service.dart';
import '../../services/hive_service.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<Map<String, dynamic>> messages = [];
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool voiceEnabled = true;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';
  bool _showVoiceDialog = false;

  String userName = 'Suresh';
  String userId = ''; // Add user ID for chat history separation
  List<KeywordModel> keywords = [];
  bool isLoading = true;

  // Sample visitor data (you can get this from your actual data)
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadUserData();
    await _loadKeywordsData();
    _initializeSpeech();
    await _loadChatHistory();

    // Only send initial greeting if no chat history exists
    if (messages.isEmpty) {
      _sendInitialGreeting();
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
      userId = prefs.getString('user_id') ?? prefs.getString('username') ?? 'default_user';
    });
  }

  Future<void> _loadKeywordsData() async {
    setState(() => isLoading = true);

    try {
      // First try to fetch from API
      keywords = await ApiService.fetchKeywords();

      // If API fails, get from Hive cache
      if (keywords.isEmpty) {
        keywords = HiveService.getKeywords();
      }

      // Debug: Print loaded keywords
      print('Loaded ${keywords.length} keywords:');
      for (var keyword in keywords) {
        print('Display: ${keyword.displayOptions}, Keywords: ${keyword.keywordsGlossary}, Action: ${keyword.appMethodToCall}');
      }
    } catch (e) {
      print('Error loading keywords: $e');
      keywords = HiveService.getKeywords();
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadChatHistory() async {
    try {
      var chatHistory = HiveService.getChatHistory(userId);

      if (chatHistory != null && chatHistory.inputOutput.isNotEmpty) {
        List<Map<String, dynamic>> loadedMessages = [];

        for (var msg in chatHistory.inputOutput) {
          // Add user message if it exists
          if (msg.userInput.isNotEmpty) {
            loadedMessages.add({
              "from": "user",
              "text": msg.userInput,
              "timestamp": msg.timestamp,
            });
          }

          // Add bot message if it exists
          if (msg.botOutput.isNotEmpty) {
            bool shouldShowOptions = msg.botOutput.contains("How can I help you") ||
                msg.botOutput.contains("following options") ||
                msg.botOutput.contains("Welcome back");

            loadedMessages.add({
              "from": "bot",
              "text": msg.botOutput,
              "timestamp": msg.timestamp,
              "quickReplies": shouldShowOptions ? _getQuickReplies() : null,
            });
          }
        }

        setState(() {
          messages = loadedMessages;
        });

        // Auto scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && messages.isNotEmpty) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  void _initializeSpeech() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onError: (val) => print('Speech Error: $val'),
      onStatus: (val) => print('Speech Status: $val'),
    );

    if (!available) {
      setState(() => voiceEnabled = false);
    }
  }

  void _sendInitialGreeting() {
    _addBotMessage("Hello $userName! I'm your KaraSahayak. How can I help you today?", showOptions: true);
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"from": "user", "text": text, "timestamp": DateTime.now()});
    });

    _botReply(text);
    _controller.clear();

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addBotMessage(String text, {bool showOptions = false}) {
    setState(() {
      messages.add({
        "from": "bot",
        "text": text,
        "timestamp": DateTime.now(),
        "quickReplies": showOptions ? _getQuickReplies() : null,
      });
    });

    // Save to Hive after adding bot message
    _saveChatToHive();

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _saveChatToHive() async {
    try {
      // Clear existing chat history for this user
      await HiveService.clearChatHistory(userId);

      // Save messages in pairs (user-bot) or individual messages
      for (int i = 0; i < messages.length; i++) {
        String userInput = "";
        String botOutput = "";
        DateTime timestamp = messages[i]["timestamp"] ?? DateTime.now();

        if (messages[i]["from"] == "user") {
          userInput = messages[i]["text"];

          // Check if next message is from bot
          if (i + 1 < messages.length && messages[i + 1]["from"] == "bot") {
            botOutput = messages[i + 1]["text"];
            timestamp = messages[i + 1]["timestamp"] ?? timestamp;
            i++; // Skip the bot message in next iteration
          }
        } else if (messages[i]["from"] == "bot") {
          botOutput = messages[i]["text"];
        }

        // Save the message pair or individual message
        if (userInput.isNotEmpty || botOutput.isNotEmpty) {
          await HiveService.addChatMessage(userId, userInput, botOutput, timestamp);
        }
      }
    } catch (e) {
      print('Error saving chat to Hive: $e');
    }
  }

  List<String> _getQuickReplies() {
    if (keywords.isEmpty) {
      return ['Register a Visitor', 'Register Grievance', 'Show Gate Pass', 'Show Map', 'Exit App'];
    }
    return keywords.map((k) => k.displayOptions).toList();
  }

  void _botReply(String userInput) {
    final input = userInput.toLowerCase().trim();

    print('User input: "$input"');
    print('Available keywords: ${keywords.length}');

    // Check against keywords with more flexible matching
    for (KeywordModel keyword in keywords) {
      bool matchFound = false;

      // Check keywords glossary with exact and partial matching
      for (String keywordStr in keyword.keywordsGlossary) {
        String cleanKeyword = keywordStr.toLowerCase().trim();

        // Exact match or contains match
        if (input == cleanKeyword || input.contains(cleanKeyword)) {
          print('Match found for "${cleanKeyword}" in input "${input}"');
          matchFound = true;
          break;
        }

        // Check for individual words
        List<String> inputWords = input.split(' ');
        List<String> keywordWords = cleanKeyword.split(' ');

        // If keyword is a single word, check if it exists in input
        if (keywordWords.length == 1 && inputWords.contains(keywordWords[0])) {
          print('Single word match found: "${keywordWords[0]}"');
          matchFound = true;
          break;
        }
      }

      // Also check display options
      if (!matchFound) {
        String displayOption = keyword.displayOptions.toLowerCase();
        if (input.contains(displayOption) || input == displayOption) {
          print('Display option match found: "${displayOption}"');
          matchFound = true;
        }
      }

      if (matchFound) {
        _addBotMessage("Sure! Let me help you with that.");
        _executeAction(keyword);
        return;
      }
    }

    // Greeting responses
    if (_isGreeting(input)) {
      _addBotMessage("Hey $userName! I'm your KaraSahayak. How can I help you today?", showOptions: true);
      return;
    }

    // Default response for unrecognized input
    _addBotMessage("Sorry, I didn't understand that. Please choose one of the following options:", showOptions: true);
  }

  bool _isGreeting(String input) {
    List<String> greetings = ['hello', 'hi', 'hey', 'namaste', 'start'];
    return greetings.any((greeting) => input.contains(greeting));
  }

  void _executeAction(KeywordModel keyword) {
    switch (keyword.appMethodToCall) {
      case 'registerVisitor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VisitHomeScreen(fromChatbot: true)),
        ).then((_) => _showReturnMessage());
        break;

      case 'registerGrievance':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GrievanceHomeScreen(fromChatbot: true)),
        ).then((_) => _showReturnMessage());
        break;

      case 'showGatepass':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => eVisitorPassScreen(visitor: visitor)),
        ).then((_) => _showReturnMessage());
        break;

      case 'showGoogleMap':
        _launchGoogleMap();
        _showReturnMessage();
        break;

      case 'exitKaraSahayak':
      case 'exit_to_dashboard':
        Navigator.pop(context);
        break;

      default:
        _addBotMessage("Action not implemented yet: ${keyword.appMethodToCall}");
    }
  }

  void _showReturnMessage() {
    Future.delayed(Duration(milliseconds: 500), () {
      _addBotMessage("Welcome back $userName! How can I help you again?", showOptions: true);
    });
  }

  void _launchGoogleMap() async {
    // Using a more standard Google Maps URL format
    const url = "https://www.google.com/maps/place/NutanTek+Solutions+LLP/@19.7251636,60.9691764,4z/data=!3m1!4b1!4m6!3m5!1s0x390ce5db65f6af0f:0xb29ad5bc8aabd76a!8m2!3d21.0680074!4d82.7525294!16s%2Fg%2F11k6fbjb7n?authuser=0&entry=ttu&g_ep=EgoyMDI1MDcyOS4wIKXMDSoASAFQAw%3D%3D";

    try {
      if (await canLaunch(url)) {
        await launch(url);
        print('Google Maps launched successfully');
      } else {
        // Fallback to browser
        const fallbackUrl = "https://www.google.com/maps/search/21.0680074,82.7525294";
        if (await canLaunch(fallbackUrl)) {
          await launch(fallbackUrl);
          print('Google Maps opened in browser');
        } else {
          print('Could not launch Google Maps');
        }
      }
    } catch (e) {
      print('Error launching Google Maps: $e');
    }
  }

  void _handleQuickReply(String text) {
    _sendMessage(text);
  }

  void _clearChat() async {
    setState(() {
      messages.clear();
    });
    await HiveService.clearChatHistory(userId);
    _sendInitialGreeting();
  }

  void _refreshChat() {
    _clearChat();
    _loadKeywordsData(); // Refresh keywords from API
  }

  // Enhanced Speech-to-Text with better language support
  void _showVoicePopup() {
    setState(() => _showVoiceDialog = true);
    _startListening(); // Auto-start listening when popup opens
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5A8BBA).withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // X button at top right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "KaraSahayak",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5A8BBA),
                            letterSpacing: 1.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _stopListening();
                            Navigator.of(context).pop();
                            setState(() {
                              _showVoiceDialog = false;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40),

                    // Animated microphone - always shows mic (not mic_off)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 800),
                          width: _isListening ? 140 : 100,
                          height: _isListening ? 140 : 100,
                          decoration: BoxDecoration(
                            color: Color(0xFF5A8BBA).withOpacity(_isListening ? 0.2 : 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: _isListening ? Color(0xFF5A8BBA) : Color(0xFF5A8BBA).withOpacity(0.7),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF5A8BBA).withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mic, // Always show mic icon, never mic_off
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    Text(
                      _isListening ? "Listening..." : "Ready to listen",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF5A8BBA),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Always show the captured text area
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(minHeight: 80),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF5A8BBA).withOpacity(0.1), Colors.grey[50]!],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Color(0xFF5A8BBA).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What you're saying:",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _voiceText.isEmpty ? "..." : _voiceText,
                            style: TextStyle(
                              fontSize: 16,
                              color: _voiceText.isEmpty ? Colors.grey[400] : Color(0xFF5A8BBA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (_voiceText.trim().isNotEmpty) {
        _sendMessage(_voiceText);
      }
      setState(() {
        _showVoiceDialog = false;
        _voiceText = '';
      });
      _stopListening();
    });
  }

  void _startListening() async {
    if (!voiceEnabled) return;

    try {
      bool available = await _speech.initialize();
      if (!available) {
        print('Speech recognition not available');
        return;
      }

      setState(() {
        _isListening = true;
        _voiceText = '';
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _voiceText = result.recognizedWords;
          });
          print('Voice recognition result: ${result.recognizedWords}');

          if (result.finalResult && _voiceText.trim().isNotEmpty) {
            // Automatically close the dialog and trigger action
            Navigator.of(context).pop(); // closes the dialog
            _sendMessage(_voiceText);
            _stopListening();

            setState(() {
              _isListening = false;
              _showVoiceDialog = false;
              _voiceText = '';
            });
          }
        },
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_IN',
      );
    } catch (e) {
      print('Error in _startListening: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _stopListening() {
    try {
      if (_isListening && _speech.isListening) {
        _speech.stop();
      }
      setState(() => _isListening = false);
    } catch (e) {
      print('Error in _stopListening: $e');
      setState(() => _isListening = false);
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message["from"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
            colors: [Colors.grey[100]!, Colors.grey[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Color(0xFF5A8BBA).withOpacity(0.1), Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF5A8BBA).withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message["text"] ?? "",
              style: TextStyle(
                fontSize: 16,
                color: isUser ? Colors.black : Color(0xFF5A8BBA),
                height: 1.4,
              ),
            ),
            if (message["quickReplies"] != null && (message["quickReplies"] as List).isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: (message["quickReplies"] as List<String>).map((reply) {
                    return InkWell(
                      onTap: () => _handleQuickReply(reply),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF5A8BBA), Color(0xFF5A8BBA).withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF5A8BBA).withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          reply,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF5A8BBA),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          textAlign: TextAlign.right,
          'KaraSahayak',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshChat,
            tooltip: 'Refresh Chat',
          ),
          PopupMenuItem(
            value: 'toggle_voice',
            child: Row(
              children: [
                Icon(
                  voiceEnabled ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5A8BBA),
          strokeWidth: 3,
        ),
      )
          : Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index]),
            ),
          ),

          // Input area
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 40,
                  offset: Offset(0, -2),
                ),
              ],
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Color(0xFF5A8BBA).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    voiceEnabled ? Icons.mic : Icons.mic_off,
                    color: voiceEnabled ? Color(0xFF5A8BBA) : Colors.grey,
                    size: 28,
                  ),
                  onPressed: voiceEnabled ? _showVoicePopup : null,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Color(0xFF5A8BBA).withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5A8BBA), Color(0xFF5A8BBA).withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF5A8BBA).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _sendMessage(_controller.text),
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }
}