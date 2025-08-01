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

  // Chat History Box Operations
  static Box<ChatHistoryModel> get chatHistoryBox => Hive.box<ChatHistoryModel>(CHATHISTORY_BOX);

  static Future<void> saveChatHistory(ChatHistoryModel chatHistory) async {
    await chatHistoryBox.put('current_chat', chatHistory);
  }

  static ChatHistoryModel? getChatHistory() {
    return chatHistoryBox.get('current_chat');
  }

  static Future<void> addChatMessage(String userInput, String botOutput) async {
    var currentHistory = getChatHistory();

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
        timestamp: DateTime.now(),
      ),
    );

    await saveChatHistory(currentHistory);
  }

  static Future<void> clearChatHistory() async {
    await chatHistoryBox.clear();
  }
}