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
}

@HiveType(typeId: 2)
class ChatHistoryModel extends HiveObject {
  @HiveField(0)
  List<String> displayOptions;

  @HiveField(1)
  List<ChatMessageModel> inputOutput;

  ChatHistoryModel({
    required this.displayOptions,
    required this.inputOutput,
  });
}