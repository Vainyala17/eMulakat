import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/keyword_model.dart';
import 'device_service.dart';
import 'hive_service.dart';

class ApiService {
  // static const String BASE_URL = 'http://192.168.0.106:5000/api/kskeywords';
  static const String BASE_URL = 'https://d953a7124a0a.ngrok-free.app/api/kskeywords';

// Add bootstrap URL (replace with your actual backend URL)
  static const String BOOTSTRAP_URL = 'http://localhost:5000/api/bootstrap';

  // Secure storage instance (using our custom implementation)
  static Future<void> _storeSecurely(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('secure_$key', value);
  }

  static Future<String?> _readSecurely(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('secure_$key');
  }

  static Future<void> _deleteSecurely(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('secure_$key');
  }

  // ============= NEW BOOTSTRAP METHODS =============

  /// Bootstrap flow - equivalent to React Native version
  static Future<Map<String, dynamic>?> bootstrapFlow() async {
    try {
      print('🚀 Starting bootstrap flow...');

      // // Step 1: Check if app key exists, if not generate it
      // String? appKey = await DeviceService.getStoredAppKey();
      // if (appKey == null || appKey.isEmpty) {
      //   appKey = DeviceService.generateAppKey();
      //   await DeviceService.storeAppKey(appKey);
      // }

      // Step 2: Get device info and fingerprint
      final deviceInfo = await DeviceService.getDeviceInfo();
      final fingerprint = await DeviceService.getDeviceFingerprint();

      // Step 3: Call bootstrap API
      final response = await http.post(
        Uri.parse(BOOTSTRAP_URL),
        headers: {
          'Content-Type': 'application/json',
          //'x-app-key': appKey,
          'x-device-fingerprint': fingerprint,
          'User-Agent': deviceInfo,
        },
        body: json.encode({}),
      ).timeout(Duration(seconds: 30));

      print('📡 Bootstrap API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final appOwnerInfo = responseData['AppOwnerInfo'];

        if (appOwnerInfo != null) {
          // Step 4: Store AppOwnerInfo securely
          await _storeSecurely('AppOwnerInfo', json.encode(appOwnerInfo));

          print('✅ Bootstrap successful');
          print('👤 Client: ${appOwnerInfo['client_name']}');

          return appOwnerInfo;
        } else {
          throw Exception('AppOwnerInfo not found in response');
        }
      } else {
        throw Exception('Bootstrap API failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Bootstrap failed: $e');

      // Try to return cached AppOwnerInfo if bootstrap fails
      final cached = await getStoredAppOwnerInfo();
      if (cached != null) {
        print('📦 Using cached AppOwnerInfo');
        return cached;
      }

      return null;
    }
  }

  /// Get stored AppOwnerInfo
  static Future<Map<String, dynamic>?> getStoredAppOwnerInfo() async {
    try {
      final storedInfo = await _readSecurely('AppOwnerInfo');
      if (storedInfo != null) {
        return json.decode(storedInfo);
      }
      return null;
    } catch (e) {
      print('❌ Error reading stored AppOwnerInfo: $e');
      return null;
    }
  }

  /// Check if bootstrap is needed
  static Future<bool> isBootstrapNeeded() async {
    final appOwnerInfo = await getStoredAppOwnerInfo();
    return appOwnerInfo == null;
  }

  /// Force refresh bootstrap data
  static Future<Map<String, dynamic>?> refreshBootstrapData() async {
    // Clear existing data
    await _deleteSecurely('AppOwnerInfo');

    // Run bootstrap flow again
    return await bootstrapFlow();
  }

  /// Get device information for debugging
  static Future<void> printDeviceInfo() async {
    try {
      final deviceInfo = await DeviceService.getDetailedDeviceInfo();
      final fingerprint = await DeviceService.getDeviceFingerprint();
      final userAgent = await DeviceService.getDeviceInfo();

      print('🔍 === DEVICE INFORMATION ===');
      print('📱 Device Details: $deviceInfo');
      print('🔐 Fingerprint: ${fingerprint.substring(0, 16)}...');
      print('🌐 User Agent: $userAgent');
      print('=== END DEVICE INFO ===');
    } catch (e) {
      print('❌ Error printing device info: $e');
    }
  }



  // FIXED: Enhanced fetch keywords with better error handling and validation
  static Future<List<KeywordModel>> fetchKeywords() async {
    try {
      print('Fetching keywords from: $BASE_URL');

      final response = await http.get(
        Uri.parse(BASE_URL),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));// Add timeout

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<KeywordModel> keywords = [];

        // Parse the "karasahayak" array from your JSON structure
        if (data.containsKey('karasahayak') && data['karasahayak'] is List) {
          List<dynamic> karasahayakList = data['karasahayak'];
          print('Found ${karasahayakList.length} items in karasahayak array');

          for (int index = 0; index < karasahayakList.length; index++) {
            var item = karasahayakList[index];
            try {
              if (item is Map<String, dynamic>) {

                // Validate required fields exist
                if (!item.containsKey('display_options') ||
                    !item.containsKey('keywords_glossary') ||
                    !item.containsKey('action_to_perform') ||
                    !item.containsKey('app_method_to_call')) {
                  print('Warning: Item $index missing required fields: $item');
                  continue;
                }

                // Handle keywords_glossary - it can be String or List
                List<String> keywordsList = [];

                if (item['keywords_glossary'] is String) {
                  keywordsList = [item['keywords_glossary']];
                } else if (item['keywords_glossary'] is List) {
                  keywordsList = List<String>.from(item['keywords_glossary']);
                } else {
                  print('Warning: keywords_glossary is neither String nor List for item $index: $item');
                  continue; // Skip this item if keywords_glossary format is invalid
                }

                // Validate that we have actual data
                String displayOptions = item['display_options']?.toString().trim() ?? '';
                String actionToPerform = item['action_to_perform']?.toString().trim() ?? '';
                String appMethodToCall = item['app_method_to_call']?.toString().trim() ?? '';

                if (displayOptions.isEmpty || appMethodToCall.isEmpty) {
                  print('Warning: Item $index has empty required fields: $item');
                  continue;
                }

                KeywordModel keyword = KeywordModel(
                  displayOptions: displayOptions,
                  keywordsGlossary: keywordsList.where((k) => k.trim().isNotEmpty).toList(),
                  actionToPerform: actionToPerform,
                  appMethodToCall: appMethodToCall,
                );

                keywords.add(keyword);
                print('✅ Parsed keyword $index: ${keyword.displayOptions}');
                print('  Keywords: ${keyword.keywordsGlossary}');
                print('  Action: ${keyword.actionToPerform}');
                print('  Method: ${keyword.appMethodToCall}');
                print('---');
              } else {
                print('Warning: Item $index is not a Map: $item');
              }
            } catch (e) {
              print('❌ Error parsing individual keyword at index $index: $e');
              print('Problematic item: $item');
            }
          }
        } else {
          print('❌ Error: "karasahayak" key not found or is not a List in API response');
          print('Available keys: ${data.keys.toList()}');
          print('Full response: $data');
        }

        if (keywords.isNotEmpty) {
          // Save to Hive only if we got valid data
          print('💾 Saving ${keywords.length} keywords to Hive...');
          await HiveService.saveKeywords(keywords);
          print('✅ Successfully saved ${keywords.length} keywords to Hive');
        } else {
          print('⚠️ Warning: No keywords were parsed from API response');
        }

        return keywords;
      } else {
        print('❌ API returned error status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load keywords: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching keywords from API: $e');

      // Return cached data from Hive if API fails
      print('🔄 Attempting to load cached keywords from Hive...');
      var cachedKeywords = HiveService.getKeywords();
      print('📦 Returning ${cachedKeywords.length} cached keywords from Hive');

      if (cachedKeywords.isEmpty) {
        print('⚠️ Warning: No cached keywords available');

        // FALLBACK: Return hardcoded keywords if everything fails
        print('🆘 Using fallback hardcoded keywords');
        return _getFallbackKeywords();
      }

      return cachedKeywords;
    }
  }

  // ADDED: Fallback keywords in case API and cache both fail
  static List<KeywordModel> _getFallbackKeywords() {
    return [
      KeywordModel(
        displayOptions: "Register a Visitor",
        keywordsGlossary: ["visitor", "register visitor", "new visitor", "add visitor", "visitor registration"],
        actionToPerform: "Launch the Visitor's Registration Form and fill up the form using Speech to Text feature",
        appMethodToCall: "VisitHomeScreen",
      ),
      KeywordModel(
        displayOptions: "Register a Grievance",
        keywordsGlossary: ["grievance", "complaint", "register grievance", "file complaint", "grievance registration"],
        actionToPerform: "Launch the Grievance Registration Form and fill up the form using Speech to Text feature",
        appMethodToCall: "GrievanceHomeScreen",
      ),
      KeywordModel(
        displayOptions: "Show the latest eGatepass",
        keywordsGlossary: ["eGatepass", "gatepass", "getpass", "gate pass", "get pass", "show gatepass", "latest gatepass", "visitor pass", "entry pass"],
        actionToPerform: "Display the latest generated eGatepass for the visitor",
        appMethodToCall: "eVisitorPassScreen",
      ),
      KeywordModel(
        displayOptions: "Show Prison to visit on Google Map",
        keywordsGlossary: ["map", "google map", "location", "prison location", "directions", "navigate", "route", "address"],
        actionToPerform: "Read the Google Map coordinates of the Prison to be visited and launch the Google Map",
        appMethodToCall: "GoogleMapScreen",
      ),
      KeywordModel(
        displayOptions: "FAQs / Help Document",
        keywordsGlossary: ["contact",
          "help",
          "ticket",
          "support",
          "faq",
          "guide",
          "documentation",
          "assistance"],
        actionToPerform: "Display the FAQs or help documentation related to the application and visiting process.",
        appMethodToCall: "HelpDocScreen",
      ),
      KeywordModel(
        displayOptions: "Exit KaraSahayak",
        keywordsGlossary: ["exit", "close", "stop", "bye", "exit karasahayak", "close chatbot", "quit", "leave"],
        actionToPerform: "Exit the KaraSahayak and redirect to Dashboard UI",
        appMethodToCall: "ExitApp",
      ),

    ];
  }

  // Enhanced method to validate API response structure
  static Future<bool> validateApiResponse() async {
    try {
      final response = await http.get(
        Uri.parse(BASE_URL),
        headers: {
        'Content-Type': 'application/json',
      },
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the response has the expected structure
        if (data.containsKey('karasahayak') && data['karasahayak'] is List) {
          List<dynamic> karasahayakList = data['karasahayak'];

          // Validate that at least one item has required fields
          for (var item in karasahayakList) {
            if (item is Map<String, dynamic> &&
                item.containsKey('display_options') &&
                item.containsKey('keywords_glossary') &&
                item.containsKey('action_to_perform') &&
                item.containsKey('app_method_to_call')) {
              print('✅ API response validation successful');
              return true;
            }
          }
        }

        print('❌ API response validation failed: Missing required fields');
        return false;
      }

      return false;
    } catch (e) {
      print('❌ API validation error: $e');
      return false;
    }
  }

  // Method to test specific keyword matching
  static Future<void> testKeywordMatching() async {
    try {
      var keywords = await fetchKeywords();

      print('\n=== KEYWORD MATCHING TEST ===');
      for (var keyword in keywords) {
        print('\nDisplay Option: "${keyword.displayOptions}"');
        print('Keywords Glossary: ${keyword.keywordsGlossary}');
        print('App Method: ${keyword.appMethodToCall}');

        // Test some sample inputs
        List<String> testInputs = ['visitor', 'register', 'grievance', 'map', 'exit'];
        for (String input in testInputs) {
          bool matches = keyword.keywordsGlossary.any((k) =>
          k.toLowerCase().contains(input.toLowerCase()) ||
              input.toLowerCase().contains(k.toLowerCase())
          );
          if (matches) {
            print('  ✓ Matches input: "$input"');
          }
        }
      }
      print('=== END TEST ===\n');
    } catch (e) {
      print('Error in keyword matching test: $e');
    }
  }

  // Optional: Test API connectivity
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse(BASE_URL),
        headers: {
        'Content-Type': 'application/json',
      },
      ).timeout(Duration(seconds: 5));

      bool isConnected = response.statusCode == 200;
      print('API Connection Test: ${isConnected ? 'SUCCESS' : 'FAILED'}');
      return isConnected;
    } catch (e) {
      print('API connection test failed: $e');
      return false;
    }
  }

  // Method to get keywords count from API without full parsing
  static Future<int> getKeywordsCount() async {
    try {
      final response = await http.get(
        Uri.parse(BASE_URL),
        headers: {
        'Content-Type': 'application/json',
      },
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('karasahayak') && data['karasahayak'] is List) {
          return (data['karasahayak'] as List).length;
        }
      }
      return 0;
    } catch (e) {
      print('Error getting keywords count: $e');
      return 0;
    }
  }

  // Debug method to print API response structure
  static Future<void> debugApiResponse() async {
    try {
      final response = await http.get(
        Uri.parse(BASE_URL),
        headers: {
        'Content-Type': 'application/json',
      },
      ).timeout(Duration(seconds: 10));

      print('\n=== API DEBUG INFO ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Parsed JSON Keys: ${data.keys.toList()}');

        if (data.containsKey('karasahayak')) {
          print('karasahayak type: ${data['karasahayak'].runtimeType}');
          if (data['karasahayak'] is List) {
            print('karasahayak length: ${(data['karasahayak'] as List).length}');

            // Print first item structure
            if ((data['karasahayak'] as List).isNotEmpty) {
              var firstItem = (data['karasahayak'] as List)[0];
              print('First item keys: ${firstItem.keys.toList()}');
              print('First item: $firstItem');
            }
          }
        }
      }
      print('=== END DEBUG ===\n');
    } catch (e) {
      print('Debug API response error: $e');
    }
  }

  // ADDED: Force refresh keywords from API
  static Future<List<KeywordModel>> forceRefreshKeywords() async {
    try {
      // Clear Hive cache first
      await HiveService.keywordsBox.clear();
      print('🗑️ Cleared Hive cache');

      // Fetch fresh data from API
      return await fetchKeywords();
    } catch (e) {
      print('❌ Error in force refresh: $e');
      return _getFallbackKeywords();
    }
  }






  // this is apis are into assets/mock


  /// 🔹 Get Dashboard Summary
  Future<Map<String, dynamic>> getDashboardSummary(String mobileNumber) async {
    // TODO: Uncomment when backend is live
    // final response = await http.get(
    //   Uri.parse("$baseUrl/getDashboardSummary/$mobileNumber"),
    //   headers: {"accessToken": "xyz"},
    // );
    // return json.decode(response.body);

    // 🔹 Mock data (temporary)
    final String response = await rootBundle.loadString('assets/mock/dashboard_summary.json');
    return json.decode(response);
  }

  /// 🔹 Get Dashboard Detailed Data (Meeting/Parole/Grievance)
  Future<Map<String, dynamic>> getDashboardDetailedData(String type) async {
    // TODO: Uncomment when backend is live
    // final response = await http.post(
    //   Uri.parse("$baseUrl/getDashboardData/7702000725"),
    //   headers: {"accessToken": "xyz"},
    //   body: {"request_type": type},
    // );
    // return json.decode(response.body);

    // 🔹 Mock data
    String path = "";
    if (type == "Meeting") path = 'assets/mock/dashboard_detailed_meeting.json';
    if (type == "Parole") path = 'assets/mock/dashboard_detailed_parole.json';
    if (type == "Grievance") path = 'assets/mock/dashboard_detailed_grievance.json';

    final String response = await rootBundle.loadString(path);
    return json.decode(response);
  }

  /// 🔹 CORRECTED - Get My Registered Inmates
  Future<Map<String, dynamic>> getMyRegisteredInmates(String mobileNumber) async {
    try {
      // TODO: Uncomment when backend is live
      // final response = await http.get(
      //   Uri.parse("$baseUrl/getMyregdinmatesSummary/$mobileNumber"),
      //   headers: {
      //     "accessToken": "xyz",
      //     "Content-Type": "application/json",
      //   },
      // );
      //
      // if (response.statusCode == 200) {
      //   return json.decode(response.body);
      // } else {
      //   throw Exception('Failed to load inmates: ${response.statusCode}');
      // }

      // 🔹 Mock data with proper error handling
      final String response = await rootBundle.loadString('assets/mock/my_registered_inmates.json');
      final Map<String, dynamic> decodedResponse = json.decode(response);

      // Validate response structure
      if (decodedResponse['status'] == 'success' && decodedResponse['prisoners'] != null) {
        return decodedResponse;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      // Log error for debugging
      print('Error in getMyRegisteredInmates: $e');

      // Return empty result instead of throwing
      return {
        'status': 'error',
        'message': 'Failed to fetch inmates',
        'prisoners': [],
        'total_inmates': 0
      };
    }
  }

  /// 🔹 Raise Meeting Request
  static Future<Map<String, dynamic>> raiseMeetingRequest(Map<String, String> body) async {
    try {
      // TODO: Uncomment when backend is live
      // final response = await http.post(
      //   Uri.parse("$baseUrl/raiseMeetingRequest/7702000725"),
      //   headers: {
      //     "accessToken": "xyz",
      //     "Content-Type": "application/json",
      //   },
      //   body: json.encode(body),
      // );
      //
      // if (response.statusCode == 200) {
      //   return json.decode(response.body);
      // } else {
      //   throw Exception('Failed to raise meeting request: ${response.statusCode}');
      // }

      // Mock success response
      final String response = await rootBundle.loadString('assets/mock/raise_meeting_success.json');
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to raise meeting request: $e');
    }
  }

  static Future<Map<String, dynamic>> raiseParoleRequest(Map<String, String> body) async {
    try {
      // TODO: Uncomment when backend is live
      // final response = await http.post(
      //   Uri.parse("$baseUrl/raiseParoleRequest/7702000725"),
      //   headers: {
      //     "accessToken": "xyz",
      //     "Content-Type": "application/json",
      //   },
      //   body: json.encode(body),
      // );
      //
      // if (response.statusCode == 200) {
      //   return json.decode(response.body);
      // } else {
      //   throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      // }

      // Simulate network delay for realistic feel
      await Future.delayed(const Duration(seconds: 2));

      // Mock success response - load from assets
      final String response = await rootBundle.loadString('assets/mock/raise_parole_success.json');
      return json.decode(response);

    } catch (e) {
      throw Exception('Failed to raise parole request: $e');
    }
  }

  /// 🔹 Raise Grievance Request
  static Future<Map<String, dynamic>> raiseGrievanceRequest(Map<String, String> body) async {
    try {
      // TODO: Uncomment when backend is live
      // final response = await http.post(
      //   Uri.parse("$baseUrl/raiseGrievanceRequest/7702000725"),
      //   headers: {
      //     "accessToken": "xyz",
      //     "Content-Type": "application/json",
      //   },
      //   body: json.encode(body),
      // );

      // Mock success response
      final String response = await rootBundle.loadString('assets/mock/raise_grievance_success.json');
      return json.decode(response);
    } catch (e) {
      throw Exception('Failed to raise grievance request: $e');
    }
  }
}
