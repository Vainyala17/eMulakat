import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/keyword_model.dart';
import 'hive_service.dart';

class ApiService {
  static const String BASE_URL = 'https://raw.githubusercontent.com/Vainyala17/firstAPI/main/karasahayak.json';

  // Fetch keywords from GitHub raw JSON and store in Hive
  static Future<List<KeywordModel>> fetchKeywords() async {
    try {
      final response = await http.get(
        Uri.parse(BASE_URL),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<KeywordModel> keywords = [];

        // Parse your JSON structure
        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            try {
              // Handle keywords_glossary - it can be String or List
              List<String> keywordsList = [];
              if (value['keywords_glossary'] is String) {
                keywordsList = [value['keywords_glossary']];
              } else if (value['keywords_glossary'] is List) {
                keywordsList = List<String>.from(value['keywords_glossary']);
              }

              KeywordModel keyword = KeywordModel(
                displayOptions: value['display_options'] ?? '',
                keywordsGlossary: keywordsList,
                actionToPerform: value['action_to_perform'] ?? '',
                appMethodToCall: value['app_method_to_call'] ?? '',
              );

              keywords.add(keyword);
              print('Parsed keyword: ${keyword.displayOptions} with keywords: ${keyword.keywordsGlossary}');
            } catch (e) {
              print('Error parsing keyword $key: $e');
            }
          }
        });

        // Save to Hive
        await HiveService.saveKeywords(keywords);

        return keywords;
      } else {
        throw Exception('Failed to load keywords: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching keywords: $e');
      return HiveService.getKeywords(); // return local copy
    }
  }
}