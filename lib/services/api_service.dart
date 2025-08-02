import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/keyword_model.dart';
import 'hive_service.dart';

class ApiService {
  static const String BASE_URL = 'http://localhost:5000/api/kskeywords';

  // Fetch keywords from API and store in Hive
  static Future<List<KeywordModel>> fetchKeywords() async {
    try {
      print('Fetching keywords from: $BASE_URL');

      final response = await http.get(
        Uri.parse(BASE_URL),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10)); // Add timeout

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

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

        if (keywords.isNotEmpty) {
          // Save to Hive only if we got valid data
          await HiveService.saveKeywords(keywords);
          print('Successfully saved ${keywords.length} keywords to Hive');
        }

        return keywords;
      } else {
        print('API returned error status: ${response.statusCode}');
        throw Exception('Failed to load keywords: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching keywords from API: $e');

      // Return cached data from Hive if API fails
      var cachedKeywords = HiveService.getKeywords();
      print('Returning ${cachedKeywords.length} cached keywords from Hive');
      return cachedKeywords;
    }
  }

  // Optional: Test API connectivity
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse(BASE_URL),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('API connection test failed: $e');
      return false;
    }
  }
}