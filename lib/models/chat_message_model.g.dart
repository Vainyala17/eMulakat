// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageModelAdapter extends TypeAdapter<ChatMessageModel> {
  @override
  final int typeId = 1;

  @override
  ChatMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageModel(
      userInput: fields[0] as String,
      botOutput: fields[1] as String,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userInput)
      ..writeByte(1)
      ..write(obj.botOutput)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatHistoryModelAdapter extends TypeAdapter<ChatHistoryModel> {
  @override
  final int typeId = 2;

  @override
  ChatHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatHistoryModel(
      displayOptions: (fields[0] as List).cast<String>(),
      inputOutput: (fields[1] as List).cast<ChatMessageModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatHistoryModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.displayOptions)
      ..writeByte(1)
      ..write(obj.inputOutput);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
