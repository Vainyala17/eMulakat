import 'package:hive_flutter/hive_flutter.dart';
import '../models/keyword_model.dart';
import '../models/chat_message_model.dart';

class HiveService {
  static const String KEYWORDS_BOX = 'keywords_box';
  static const String CHATHISTORY_BOX = 'chathistory_box';

  // Initialize Hive
  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(KeywordModelAdapter());
    Hive.registerAdapter(ChatMessageModelAdapter());
    Hive.registerAdapter(ChatHistoryModelAdapter());

    // Open boxes
    await Hive.openBox<KeywordModel>(KEYWORDS_BOX);
    await Hive.openBox<ChatHistoryModel>(CHATHISTORY_BOX);
  }

  // Keywords Box Operations - FIXED: Use consistent box name
  static Box<KeywordModel> get keywordsBox => Hive.box<KeywordModel>(KEYWORDS_BOX);

  // FIXED: Use consistent box name and proper error handling
  static Future<void> saveKeywords(List<KeywordModel> keywords) async {
    try {
      // Use the same box name consistently
      final box = keywordsBox;

      // Clear existing data first
      await box.clear();

      // Add all keywords
      for (int i = 0; i < keywords.length; i++) {
        await box.put(i, keywords[i]);
        print('Saved keyword $i: ${keywords[i].displayOptions} -> ${keywords[i].appMethodToCall}');
      }

      print('Successfully saved ${keywords.length} keywords to Hive');
    } catch (e) {
      print('Error saving keywords to Hive: $e');
      throw e;
    }
  }

  // FIXED: Use consistent box name
  static List<KeywordModel> getKeywords() {
    try {
      final box = keywordsBox;
      List<KeywordModel> keywords = box.values.toList();

      print('Retrieved ${keywords.length} keywords from Hive:');
      for (int i = 0; i < keywords.length; i++) {
        print('[$i] ${keywords[i].displayOptions} -> ${keywords[i].appMethodToCall}');
      }

      return keywords;
    } catch (e) {
      print('Error getting keywords from Hive: $e');
      return [];
    }
  }

  // Chat History Box Operations with User-Specific Storage
  static Box<ChatHistoryModel> get chatHistoryBox => Hive.box<ChatHistoryModel>(CHATHISTORY_BOX);

  // Get chat history for a specific user
  static ChatHistoryModel? getChatHistory(String userId) {
    return chatHistoryBox.get('chat_$userId');
  }

  // Save chat history for a specific user
  static Future<void> saveChatHistory(String userId, ChatHistoryModel chatHistory) async {
    await chatHistoryBox.put('chat_$userId', chatHistory);
  }

  // Add a chat message for a specific user
  static Future<void> addChatMessage(String userId, String userInput, String botOutput, [DateTime? timestamp]) async {
    var currentHistory = getChatHistory(userId);

    if (currentHistory == null) {
      currentHistory = ChatHistoryModel(
        displayOptions: [],
        inputOutput: [],
      );
    }

    currentHistory.inputOutput.add(
      ChatMessageModel(
        userInput: userInput,
        botOutput: botOutput,
        timestamp: timestamp ?? DateTime.now(),
      ),
    );

    await saveChatHistory(userId, currentHistory);
  }

  // Clear chat history for a specific user
  static Future<void> clearChatHistory(String userId) async {
    await chatHistoryBox.delete('chat_$userId');
  }

  // Clear all chat histories (for debugging or admin purposes)
  static Future<void> clearAllChatHistories() async {
    await chatHistoryBox.clear();
  }

  // Get all user IDs who have chat history
  static List<String> getAllChatUsers() {
    return chatHistoryBox.keys
        .where((key) => key.toString().startsWith('chat_'))
        .map((key) => key.toString().substring(5)) // Remove 'chat_' prefix
        .toList();
  }

  // Check if user has existing chat history
  static bool hasExistingChat(String userId) {
    var history = getChatHistory(userId);
    return history != null && history.inputOutput.isNotEmpty;
  }

  // ADDED: Debug method to check box contents
  static void debugKeywordsBox() {
    try {
      final box = keywordsBox;
      print('=== KEYWORDS BOX DEBUG ===');
      print('Box name: ${box.name}');
      print('Box length: ${box.length}');
      print('Box keys: ${box.keys.toList()}');
      print('Box is open: ${box.isOpen}');

      if (box.isNotEmpty) {
        print('First keyword: ${box.getAt(0)?.displayOptions}');
      }
      print('=== END DEBUG ===');
    } catch (e) {
      print('Error in debugKeywordsBox: $e');
    }
  }
}