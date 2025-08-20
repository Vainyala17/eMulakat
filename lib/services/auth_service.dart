import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const String tokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String specialUserKey = 'special_user';
  static const String isSpecialUserKey = 'is_special_user';
  static const String loginUrl = 'https://2faedd303dbe.ngrok-free.app/api/auth/login';

  // Store token
  static Future<void> saveToken(String token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(tokenKey, token);
      print('Token saved successfully');
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  // Store refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(refreshTokenKey, refreshToken);
    } catch (e) {
      print('Error saving refresh token: $e');
    }
  }

  // Get token
  static Future<String?> getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(refreshTokenKey);
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  // Clear all tokens
  static Future<void> clearTokens() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(tokenKey);
      await prefs.remove(refreshTokenKey);
      await prefs.remove(specialUserKey);
      await prefs.remove(isSpecialUserKey);
      print('All tokens and user data cleared successfully');
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }

  // Check if user is special user
  static Future<bool> isSpecialUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(isSpecialUserKey) ?? false;
    } catch (e) {
      print('Error checking special user status: $e');
      return false;
    }
  }

  // Get special user identifier
  static Future<String?> getSpecialUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(specialUserKey);
    } catch (e) {
      print('Error getting special user: $e');
      return null;
    }
  }

  // Enhanced token validation that considers special users
  static Future<bool> isTokenValid() async {
    try {
      // Check if it's a special user first
      bool special = await isSpecialUser();
      if (special) {
        String? specialUser = await getSpecialUser();
        if (specialUser != null && specialUser.isNotEmpty) {
          print('Special user session valid: $specialUser');
          return true;
        }
      }

      // Check regular JWT token
      String? token = await getToken();
      if (token == null || token.isEmpty) {
        print('No token found');
        return false;
      }

      bool isExpired = JwtDecoder.isExpired(token);
      print('Token expired: $isExpired');
      return !isExpired;
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }

  // Get user data from token or special user
  static Future<Map<String, dynamic>?> getUserFromToken() async {
    try {
      // Check special user first
      bool special = await isSpecialUser();
      if (special) {
        String? specialUser = await getSpecialUser();
        if (specialUser != null) {
          return {
            'username': specialUser,
            'mobile': specialUser,
            'user_type': 'special',
            'is_special': true,
          };
        }
      }

      // Get from JWT token
      String? token = await getToken();
      if (token == null) return null;

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  // Enhanced login with better error handling
  static Future<Map<String, dynamic>> loginUser(String mobileOrEmail, String password) async {
    try {
      print('Attempting login for: $mobileOrEmail');

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': mobileOrEmail.trim(),
          'password': password,
        }),
      ).timeout(Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // Handle different response structures
        String? token;
        Map<String, dynamic>? userData;

        // Try different token field names
        if (body['token'] != null) {
          token = body['token'];
        } else if (body['access_token'] != null) {
          token = body['access_token'];
        } else if (body['accessToken'] != null) {
          token = body['accessToken'];
        } else if (body['data'] != null && body['data']['token'] != null) {
          token = body['data']['token'];
        }

        // Extract user data
        if (body['user'] != null) {
          userData = body['user'];
        } else if (body['data'] != null) {
          userData = body['data'];
        }

        print('Extracted token: ${token != null ? "Found" : "Not found"}');
        print('Response keys: ${body.keys.toList()}');

        if (token != null && token.isNotEmpty) {
          await saveToken(token);

          // Save refresh token if available
          if (body['refresh_token'] != null) {
            await saveRefreshToken(body['refresh_token']);
          } else if (body['refreshToken'] != null) {
            await saveRefreshToken(body['refreshToken']);
          }

          return {
            'success': true,
            'token': token,
            'message': body['message'] ?? 'Login successful',
            'user': userData,
          };
        } else {
          return {
            'success': false,
            'message': 'Authentication token not found in server response',
          };
        }
      } else if (response.statusCode == 401) {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'message': body['message'] ?? 'Invalid credentials. Please check your login details.',
        };
      } else if (response.statusCode == 422) {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'message': body['message'] ?? 'Validation failed. Please check your input.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'User not found. Please check your credentials.',
        };
      } else if (response.statusCode >= 500) {
        return {
          'success': false,
          'message': 'Server error. Please try again later.',
        };
      } else {
        final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'message': body['message'] ?? 'Login failed. Status: ${response.statusCode}',
        };
      }
    } on http.ClientException catch (e) {
      print('HTTP Client error: $e');
      return {
        'success': false,
        'message': 'Network connection error. Please check your internet connection.',
      };
    } on FormatException catch (e) {
      print('JSON parsing error: $e');
      return {
        'success': false,
        'message': 'Invalid server response format.',
      };
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Check session and redirect if needed
  static Future<bool> checkAndHandleSession(BuildContext context, {String loginRoute = '/login'}) async {
    try {
      bool isValid = await isTokenValid();
      if (!isValid) {
        await clearTokens();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Session expired. Please login again."),
              backgroundColor: Colors.red,
            ),
          );

          Navigator.of(context).pushNamedAndRemoveUntil(
            loginRoute,
                (route) => false,
          );
        }
        return false;
      }
      return true;
    } catch (e) {
      print('Session check error: $e');
      return false;
    }
  }

  // Enhanced logout
  static Future<void> logout(BuildContext context, {String loginRoute = '/login'}) async {
    try {
      await clearTokens();

      // Small delay to ensure data is cleared
      await Future.delayed(Duration(milliseconds: 300));

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          loginRoute,
              (route) => false,
        );
      }
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Get headers with authorization
  static Future<Map<String, String>> getAuthHeaders() async {
    String? token = await getToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Test connection to auth endpoint
  static Future<bool> testAuthConnection() async {
    try {
      final response = await http.get(
        Uri.parse(loginUrl.replaceAll('/login', '/health')), // Assuming there's a health endpoint
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Auth connection test failed: $e');
      return false;
    }
  }

  // Refresh token if expired
  static Future<Map<String, dynamic>> refreshAuthToken() async {
    try {
      String? refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return {
          'success': false,
          'message': 'No refresh token available',
        };
      }

      final response = await http.post(
        Uri.parse(loginUrl.replaceAll('/login', '/refresh')),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        String? newToken = body['token'] ?? body['access_token'] ?? body['accessToken'];

        if (newToken != null) {
          await saveToken(newToken);
          return {
            'success': true,
            'token': newToken,
          };
        }
      }

      return {
        'success': false,
        'message': 'Token refresh failed',
      };
    } catch (e) {
      print('Token refresh error: $e');
      return {
        'success': false,
        'message': 'Token refresh error: $e',
      };
    }
  }

  // Debug method to print current auth state
  static Future<void> debugAuthState() async {
    print('\n=== AUTH DEBUG STATE ===');

    String? token = await getToken();
    String? refreshToken = await getRefreshToken();
    bool special = await isSpecialUser();
    String? specialUser = await getSpecialUser();
    bool valid = await isTokenValid();

    print('Token: ${token != null ? "Present (${token.length} chars)" : "None"}');
    print('Refresh Token: ${refreshToken != null ? "Present" : "None"}');
    print('Special User: $special');
    print('Special User ID: $specialUser');
    print('Session Valid: $valid');

    if (token != null) {
      try {
        bool expired = JwtDecoder.isExpired(token);
        DateTime? expiry = JwtDecoder.getExpirationDate(token);
        print('Token Expired: $expired');
        print('Token Expiry: $expiry');
      } catch (e) {
        print('Token decode error: $e');
      }
    }

    print('=== END AUTH DEBUG ===\n');
  }
}