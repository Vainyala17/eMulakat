
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../dashboard/evisitor_pass_screen.dart';
import '../../dashboard/grievance/grievance_details_screen.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';
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
  String userId = '';
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
    status: VisitStatus.expired,
    startTime: '14:00',
    endTime: '16:30',
    dayOfWeek: 'Friday',
    prison: 'null',
  );

  @override
  void initState() {
    super.initState();
    _initializeApp();
    //AuthService.checkAndHandleSession(context);
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

  // FIXED: Better keyword loading with proper debugging
  Future<void> _loadKeywordsData() async {
    setState(() => isLoading = true);

    try {
      print('=== LOADING KEYWORDS DEBUG ===');

      // Clear existing keywords
      keywords.clear();

      // First try to fetch from API
      keywords = await ApiService.fetchKeywords();
      print('Fetched ${keywords.length} keywords from API');

      // If API failed, try to get from Hive cache
      if (keywords.isEmpty) {
        print('API returned empty, trying Hive cache...');
        keywords = HiveService.getKeywords();
        print('Retrieved ${keywords.length} keywords from Hive cache');
      }

      // Debug keywords that were loaded
      print('=== FINAL KEYWORDS LOADED ===');
      print('Total keywords: ${keywords.length}');

      for (int i = 0; i < keywords.length; i++) {
        var keyword = keywords[i];
        print('[$i] Display: "${keyword.displayOptions}"');
        print('[$i] Keywords: ${keyword.keywordsGlossary}');
        print('[$i] Action: "${keyword.actionToPerform}"');
        print('[$i] Method: "${keyword.appMethodToCall}"');
        print('---');
      }

      // Additional debugging
      HiveService.debugKeywordsBox();

      if (keywords.isEmpty) {
        print('❌ WARNING: No keywords loaded! This will cause "No options available"');
      } else {
        print('✅ Successfully loaded ${keywords.length} keywords');
      }

    } catch (e) {
      print('❌ Error loading keywords: $e');
      // Try one more time from Hive
      keywords = HiveService.getKeywords();
      print('Fallback: Retrieved ${keywords.length} keywords from Hive');
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

    try {
      bool available = await _speech.initialize(
        onError: (val) {
          print('Speech initialization error: $val');
          setState(() {
            voiceEnabled = false;
          });
        },
        onStatus: (val) {
          print('Speech initialization status: $val');
        },
      );

      setState(() {
        voiceEnabled = available;
      });

      if (!available) {
        print('Speech recognition not available on this device');
      } else {
        print('Speech recognition initialized successfully');

        // Check available locales (optional - for debugging)
        var locales = await _speech.locales();
        print('Available locales: ${locales.map((l) => l.localeId).toList()}');
      }
    } catch (e) {
      print('Error initializing speech: $e');
      setState(() {
        voiceEnabled = false;
      });
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

  // FIXED: Dynamic quick replies generation from API data
  List<String> _getQuickReplies() {
    print('Generating quick replies from ${keywords.length} keywords');

    if (keywords.isEmpty) {
      print('❌ No keywords available for quick replies');
      return ['No options available'];
    }

    // Return display options from API
    List<String> replies = keywords.map((k) => k.displayOptions).toList();
    print('Generated ${replies.length} quick replies: $replies');
    return replies;
  }

  // FIXED: Enhanced bot reply with better keyword matching
  // FIXED: Enhanced bot reply with better keyword matching
  void _botReply(String userInput) {
    final input = userInput.toLowerCase().trim();

    print('=== BOT REPLY DEBUG ===');
    print('User input: "$input"');
    print('Available keywords: ${keywords.length}');

    // Enhanced keyword matching with priority order
    KeywordModel? matchedKeyword;

    // PRIORITY 1: Exact display option match (highest priority)
    for (var keyword in keywords) {
      String displayOption = keyword.displayOptions.toLowerCase().trim();
      if (input == displayOption) {
        print('✅ Exact display option match found: "${displayOption}"');
        matchedKeyword = keyword;
        break;
      }
    }

    // PRIORITY 2: Exact keyword match from glossary
    if (matchedKeyword == null) {
      for (var keyword in keywords) {
        for (var keywordStr in keyword.keywordsGlossary) {
          String cleanKeyword = keywordStr.toLowerCase().trim();
          if (input == cleanKeyword) {
            print('✅ Exact keyword match found: "${cleanKeyword}"');
            matchedKeyword = keyword;
            break;
          }
        }
        if (matchedKeyword != null) break;
      }
    }

    // PRIORITY 3: Multi-word phrase matching (more specific)
    if (matchedKeyword == null) {
      List<String> inputWords = input.split(' ').where((word) => word.length > 2).toList();

      if (inputWords.length >= 2) { // Only for multi-word inputs
        for (var keyword in keywords) {
          // Check display options
          String displayOption = keyword.displayOptions.toLowerCase().trim();
          List<String> displayWords = displayOption.split(' ').where((word) => word.length > 2).toList();

          // Calculate word overlap percentage
          int matchCount = 0;
          for (String word in inputWords) {
            if (displayWords.any((dw) => dw.contains(word) || word.contains(dw))) {
              matchCount++;
            }
          }

          // Require at least 60% word match for multi-word phrases
          double matchPercentage = matchCount / inputWords.length;
          if (matchPercentage >= 0.6) {
            print('✅ Multi-word phrase match found: "${displayOption}" (${(matchPercentage * 100).round()}% match)');
            matchedKeyword = keyword;
            break;
          }

          // Check keywords glossary
          for (var keywordStr in keyword.keywordsGlossary) {
            String cleanKeyword = keywordStr.toLowerCase().trim();
            List<String> keywordWords = cleanKeyword.split(' ').where((word) => word.length > 2).toList();

            matchCount = 0;
            for (String word in inputWords) {
              if (keywordWords.any((kw) => kw.contains(word) || word.contains(kw))) {
                matchCount++;
              }
            }

            matchPercentage = matchCount / inputWords.length;
            if (matchPercentage >= 0.6) {
              print('✅ Multi-word keyword match found: "${cleanKeyword}" (${(matchPercentage * 100).round()}% match)');
              matchedKeyword = keyword;
              break;
            }
          }
          if (matchedKeyword != null) break;
        }
      }
    }

    // PRIORITY 4: Partial contains matching (more flexible)
    if (matchedKeyword == null) {
      for (var keyword in keywords) {
        // Check display options
        String displayOption = keyword.displayOptions.toLowerCase().trim();
        if (input.contains(displayOption) && displayOption.length > 3) {
          print('✅ Display option contains match found: "${displayOption}"');
          matchedKeyword = keyword;
          break;
        }
        if (displayOption.contains(input) && input.length > 3) {
          print('✅ Input contained in display option: "${displayOption}"');
          matchedKeyword = keyword;
          break;
        }

        // Check keywords glossary
        for (var keywordStr in keyword.keywordsGlossary) {
          String cleanKeyword = keywordStr.toLowerCase().trim();
          if (input.contains(cleanKeyword) && cleanKeyword.length > 3) {
            print('✅ Keyword contains match found: "${cleanKeyword}"');
            matchedKeyword = keyword;
            break;
          }
          if (cleanKeyword.contains(input) && input.length > 3) {
            print('✅ Input contained in keyword: "${cleanKeyword}"');
            matchedKeyword = keyword;
            break;
          }
        }
        if (matchedKeyword != null) break;
      }
    }

    // PRIORITY 5: Single word matching (lowest priority, most restrictive)
    if (matchedKeyword == null) {
      List<String> inputWords = input.split(' ').where((word) => word.length > 3).toList(); // Only longer words

      for (var keyword in keywords) {
        // Check display options
        String displayOption = keyword.displayOptions.toLowerCase().trim();
        List<String> displayWords = displayOption.split(' ').where((word) => word.length > 3).toList();

        // For single word matching, require exact word match or very close match
        bool hasStrongMatch = false;
        for (String inputWord in inputWords) {
          for (String displayWord in displayWords) {
            if (inputWord == displayWord ||
                (inputWord.length > 4 && displayWord.length > 4 &&
                    (inputWord.contains(displayWord) || displayWord.contains(inputWord)))) {
              hasStrongMatch = true;
              break;
            }
          }
          if (hasStrongMatch) break;
        }

        if (hasStrongMatch) {
          print('✅ Strong single word match found: "${displayOption}"');
          matchedKeyword = keyword;
          break;
        }

        // Check keywords glossary with same logic
        for (var keywordStr in keyword.keywordsGlossary) {
          String cleanKeyword = keywordStr.toLowerCase().trim();
          List<String> keywordWords = cleanKeyword.split(' ').where((word) => word.length > 3).toList();

          hasStrongMatch = false;
          for (String inputWord in inputWords) {
            for (String keywordWord in keywordWords) {
              if (inputWord == keywordWord ||
                  (inputWord.length > 4 && keywordWord.length > 4 &&
                      (inputWord.contains(keywordWord) || keywordWord.contains(inputWord)))) {
                hasStrongMatch = true;
                break;
              }
            }
            if (hasStrongMatch) break;
          }

          if (hasStrongMatch) {
            print('✅ Strong single keyword match found: "${cleanKeyword}"');
            matchedKeyword = keyword;
            break;
          }
        }
        if (matchedKeyword != null) break;
      }
    }

    print('=== END BOT REPLY DEBUG ===');

    // If match found, execute action
    if (matchedKeyword != null) {
      _addBotMessage("Sure! Let me help you with ${matchedKeyword.displayOptions}.");
      _executeAction(matchedKeyword);
      return;
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

  // FIXED: Enhanced action execution with better error handling
  // FIXED: Enhanced action execution with better error handling
  void _executeAction(KeywordModel keyword) {
    print('=== EXECUTE ACTION DEBUG ===');
    print('Keyword Display: "${keyword.displayOptions}"');
    print('Keyword Method: "${keyword.appMethodToCall}"');
    print('Keyword Action: "${keyword.actionToPerform}"');

    String pageName = keyword.appMethodToCall.trim();
    print('Trimmed pageName: "$pageName"');

    try {
      switch (pageName) {
        case 'VisitHomeScreen':
          print('✅ Navigating to VisitHomeScreen');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MeetFormScreen(selectedIndex: 1,showVisitCards: true,)),
          ).then((_) {
            _showReturnMessage();
          }).catchError((error) {
            print('❌ Navigation error to VisitHomeScreen: $error');
            _addBotMessage("Sorry, I couldn't open ${keyword.displayOptions}. Please try again later.", showOptions: true);
          });
          break;

        case 'GrievanceHomeScreen':
          print('✅ Navigating to GrievanceHomeScreen');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GrievanceDetailsScreen(fromChatbot: true)),
          ).then((_) {
            _showReturnMessage();
          }).catchError((error) {
            print('❌ Navigation error to GrievanceHomeScreen: $error');
            _addBotMessage("Sorry, I couldn't open ${keyword.displayOptions}. Please try again later.", showOptions: true);
          });
          break;

        case 'eVisitorPassScreen':
          print('✅ Navigating to eVisitorPassScreen');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => eVisitorPassScreen(visitor: visitor)),
          ).then((_) {
            _showReturnMessage();
          }).catchError((error) {
            print('❌ Navigation error to eVisitorPassScreen: $error');
            _addBotMessage("Sorry, I couldn't open ${keyword.displayOptions}. Please try again later.", showOptions: true);
          });
          break;

        case 'GoogleMapScreen':
        case 'showGoogleMap':
          print('✅ Opening Google Maps');
          _launchGoogleMap();
          _showReturnMessage();
          break;

        case 'HelpDocScreen':
          print('✅ Opening FAQs Page');
          _launchHelpDoc();
          _showReturnMessage();
          break;

        case 'ExitApp':
        case 'exitKaraSahayak':
          print('✅ Exiting app');
          Navigator.pop(context);
          break;

        default:
          print('❌ Unknown action: $pageName');
          _addBotMessage("Sorry, '${keyword.displayOptions}' feature is not available right now. Please try another option.", showOptions: true);
      }
    } catch (e) {
      print('❌ Error executing action for ${keyword.displayOptions}: $e');
      _addBotMessage("Sorry, I couldn't open ${keyword.displayOptions}. Please try again later.", showOptions: true);
    }

    print('=== END EXECUTE ACTION DEBUG ===');
  }


  void _showReturnMessage() {
    Future.delayed(Duration(milliseconds: 500), () {
      _addBotMessage("Welcome back $userName! How can I help you again?", showOptions: true);
    });
  }

  void _launchHelpDoc() async {
    const url = "https://eprisons.nic.in/CitiZenService/Login/FAQ";

    try {
      if (await canLaunch(url)) {
        await launch(url);
        print('FAQ page launched successfully');
      } else {
        print('Could not launch FAQ page');
      }
    } catch (e) {
      print('Error launching FAQ page: $e');
    }
  }
  void _launchGoogleMap() async {
    // Using a more standard Google Maps URL format
    const url = "https://www.google.com/maps/place/NutanTek+Solutions+LLP/@19.7251636,60.9691764,4z/data=!3m1!4b1!4m6!3m5!1s0x390ce5db65f6af0f:0xb29ad5bc8aabd76a!8m2!3d21.0680074!4d82.7525294!16s%2Fg%2F11k6fbjb7n?authuser=0&entry=ttu&g_ep=EgoyMDI1MDczMC4wIKXMDSoASAFQAw%3D%3D";

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
      // Stop any existing listening session first
      if (_speech.isListening) {
        await _speech.stop();
      }

      // Initialize speech if not already done
      bool available = await _speech.initialize(
        onError: (val) {
          print('Speech Error: $val');
          setState(() {
            _isListening = false;
          });
        },
        onStatus: (val) {
          print('Speech Status: $val');
          if (val == 'done' || val == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
      );

      if (!available) {
        print('Speech recognition not available');
        setState(() {
          voiceEnabled = false;
          _isListening = false;
        });
        return;
      }

      setState(() {
        _isListening = true;
        _voiceText = '';
      });

      // Start listening with proper configuration
      await _speech.listen(
        onResult: (result) {
          print('Voice recognition result: ${result.recognizedWords}');
          print('Is final result: ${result.finalResult}');
          setState(() {
            _voiceText = result.recognizedWords;
          });
          // Only process final results to avoid premature closing
          if (result.finalResult && _voiceText.trim().isNotEmpty) {
            print('Final result received, processing...');
            // Stop listening
            _speech.stop();
            // Close dialog after a short delay
            Future.delayed(Duration(milliseconds: 500), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
              _sendMessage(_voiceText);

              setState(() {
                _isListening = false;
                _showVoiceDialog = false;
                _voiceText = '';
              });
            });
          }
        },
        listenFor: Duration(seconds: 30), // Increased listening duration
        pauseFor: Duration(seconds: 5),   // Increased pause duration
        partialResults: true,
        onSoundLevelChange: (level) {
          // Optional: You can use this to show sound level indication
          print('Sound level: $level');
        },
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
        localeId: 'en_IN', // You can also try 'en_US' if 'en_IN' doesn't work well
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
      if (_speech.isListening) {
        _speech.stop();
        print('Speech listening stopped');
      }
      setState(() {
        _isListening = false;
      });
    } catch (e) {
      print('Error in _stopListening: $e');
      setState(() {
        _isListening = false;
      });
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
            // Dark background for bot messages
            colors: [Color(0xFF5A8BBA), Color(0xFF80B0EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? Color(0xFF7DBCED).withOpacity(0.1)
                  : Colors.black.withOpacity(0.2),
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
                color: isUser ? Colors.black : Colors.white, // White text for dark background
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
                          // Light colored buttons
                          gradient: LinearGradient(
                            colors: [Color(0xFF9AC7F3), Colors.grey[100]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Color(0xFF5A8BBA).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          reply,
                          style: TextStyle(
                            color: Color(0xFF2C3E50), // Dark text on light buttons
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle_voice') {
                setState(() {
                  voiceEnabled = !voiceEnabled;
                });
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'toggle_voice',
                child: Row(
                  children: [
                    Icon(
                      voiceEnabled ? Icons.mic_off : Icons.mic,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 8),
                    Text(voiceEnabled ? 'Disable Voice' : 'Enable Voice'),
                  ],
                ),
              ),
            ],
            icon: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF5A8BBA),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading KaraSahayak...',
              style: TextStyle(
                color: Color(0xFF5A8BBA),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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