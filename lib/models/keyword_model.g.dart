// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyword_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KeywordModelAdapter extends TypeAdapter<KeywordModel> {
  @override
  final int typeId = 0;

  @override
  KeywordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KeywordModel(
      displayOptions: fields[0] as String,
      keywordsGlossary: (fields[1] as List).cast<String>(),
      actionToPerform: fields[2] as String,
      appMethodToCall: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KeywordModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.displayOptions)
      ..writeByte(1)
      ..write(obj.keywordsGlossary)
      ..writeByte(2)
      ..write(obj.actionToPerform)
      ..writeByte(3)
      ..write(obj.appMethodToCall);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeywordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
