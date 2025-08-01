import 'package:hive/hive.dart';

part 'keyword_model.g.dart';

@HiveType(typeId: 0)
class KeywordModel extends HiveObject {
  @HiveField(0)
  String displayOptions;

  @HiveField(1)
  List<String> keywordsGlossary;

  @HiveField(2)
  String actionToPerform;

  @HiveField(3)
  String appMethodToCall;

  KeywordModel({
    required this.displayOptions,
    required this.keywordsGlossary,
    required this.actionToPerform,
    required this.appMethodToCall,
  });

  factory KeywordModel.fromJson(Map<String, dynamic> json) {
    return KeywordModel(
      displayOptions: json['display_options'],
      keywordsGlossary: json['keywords_glossary'] is List
          ? List<String>.from(json['keywords_glossary'])
          : [json['keywords_glossary'].toString()],
      actionToPerform: json['action_to_perform'],
      appMethodToCall: json['app_method_to_call'],
    );
  }
}
