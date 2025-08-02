import 'package:hive/hive.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 1)
class ChatMessageModel extends HiveObject {
  @HiveField(0)
  String userInput;

  @HiveField(1)
  String botOutput;

  @HiveField(2)
  DateTime timestamp;

  ChatMessageModel({
    required this.userInput,
    required this.botOutput,
    required this.timestamp,
  });

  // Helper methods for better data handling
  bool get hasUserInput => userInput.isNotEmpty;
  bool get hasBotOutput => botOutput.isNotEmpty;
  bool get isEmpty => userInput.isEmpty && botOutput.isEmpty;

  @override
  String toString() {
    return 'ChatMessageModel(userInput: $userInput, botOutput: $botOutput, timestamp: $timestamp)';
  }
}

@HiveType(typeId: 2)
class ChatHistoryModel extends HiveObject {
  @HiveField(0)
  List<String> displayOptions;

  @HiveField(1)
  List<ChatMessageModel> inputOutput;

  @HiveField(2, defaultValue: null)
  String? userId; // Optional field to track which user this belongs to

  @HiveField(3, defaultValue: null)
  DateTime? lastUpdated; // Track when this was last updated

  ChatHistoryModel({
    required this.displayOptions,
    required this.inputOutput,
    this.userId,
    this.lastUpdated,
  });

  // Helper methods
  int get messageCount => inputOutput.length;
  bool get isEmpty => inputOutput.isEmpty;
  DateTime get lastMessageTime => inputOutput.isNotEmpty
      ? inputOutput.last.timestamp
      : DateTime.now();

  // Add a new message to the history
  void addMessage(ChatMessageModel message) {
    inputOutput.add(message);
    lastUpdated = DateTime.now();
  }

  // Clear all messages
  void clearMessages() {
    inputOutput.clear();
    lastUpdated = DateTime.now();
  }

  @override
  String toString() {
    return 'ChatHistoryModel(userId: $userId, messageCount: $messageCount, lastUpdated: $lastUpdated)';
  }
}