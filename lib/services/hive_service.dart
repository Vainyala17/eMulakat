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

  // Keywords Box Operations
  static Box<KeywordModel> get keywordsBox => Hive.box<KeywordModel>(KEYWORDS_BOX);

  static Future<void> saveKeywords(List<KeywordModel> keywords) async {
    await keywordsBox.clear();
    for (int i = 0; i < keywords.length; i++) {
      await keywordsBox.put(i, keywords[i]);
    }
  }

  static List<KeywordModel> getKeywords() {
    return keywordsBox.values.toList();
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
}