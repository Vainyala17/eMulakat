// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
//
// class AuthService {
//   static const String tokenKey = 'jwt_token';
//   static const String refreshTokenKey = 'refresh_token';
//   static const String loginUrl = 'http://192.168.0.106:5000/api/auth/login';
//
//   // Store token
//   static Future<void> saveToken(String token) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString(tokenKey, token);
//       print('Token saved successfully');
//     } catch (e) {
//       print('Error saving token: $e');
//     }
//   }
//
//   // Store refresh token (if your API provides one)
//   static Future<void> saveRefreshToken(String refreshToken) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString(refreshTokenKey, refreshToken);
//     } catch (e) {
//       print('Error saving refresh token: $e');
//     }
//   }
//
//   // Get token
//   static Future<String?> getToken() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       return prefs.getString(tokenKey);
//     } catch (e) {
//       print('Error getting token: $e');
//       return null;
//     }
//   }
//
//   // Get refresh token
//   static Future<String?> getRefreshToken() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       return prefs.getString(refreshTokenKey);
//     } catch (e) {
//       print('Error getting refresh token: $e');
//       return null;
//     }
//   }
//
//   // Clear all tokens
//   static Future<void> clearTokens() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.remove(tokenKey);
//       await prefs.remove(refreshTokenKey);
//       print('Tokens cleared successfully');
//     } catch (e) {
//       print('Error clearing tokens: $e');
//     }
//   }
//
//   // Check if token exists and is valid
//   static Future<bool> isTokenValid() async {
//     try {
//       String? token = await getToken();
//       if (token == null || token.isEmpty) {
//         print('No token found');
//         return false;
//       }
//
//       bool isExpired = JwtDecoder.isExpired(token);
//       print('Token expired: $isExpired');
//       return !isExpired;
//     } catch (e) {
//       print('Error checking token validity: $e');
//       return false;
//     }
//   }
//
//   // Get user data from token
//   static Future<Map<String, dynamic>?> getUserFromToken() async {
//     try {
//       String? token = await getToken();
//       if (token == null) return null;
//
//       Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//       return decodedToken;
//     } catch (e) {
//       print('Error decoding token: $e');
//       return null;
//     }
//   }
//
//   // Login request with improved error handling
//   static Future<Map<String, dynamic>> loginUser(String mobileOrEmail, String password) async {
//     try {
//       print('Attempting login for: $mobileOrEmail');
//
//       final response = await http.post(
//         Uri.parse(loginUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode({
//           'username': mobileOrEmail.trim(),
//           'password': password,
//         }),
//       ).timeout(Duration(seconds: 30));
//
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final body = jsonDecode(response.body);
//
//         // Check different possible response structures
//         String? token;
//         if (body['token'] != null) {
//           token = body['token'];
//         } else if (body['access_token'] != null) {
//           token = body['access_token'];
//         } else if (body['accessToken'] != null) { // <-- Add this line
//           token = body['accessToken'];
//         } else if (body['data'] != null && body['data']['token'] != null) {
//           token = body['data']['token'];
//         }
//         print('Response keys: ${body.keys}');
//
//         if (token != null && token.isNotEmpty) {
//           await saveToken(token);
//
//           // Save refresh token if available
//           if (body['refresh_token'] != null) {
//             await saveRefreshToken(body['refresh_token']);
//           }
//
//           return {
//             'success': true,
//             'token': token,
//             'message': body['message'] ?? 'Login successful',
//             'user': body['user'] ?? body['data']
//           };
//         } else {
//           return {
//             'success': false,
//             'message': 'Token not found in response'
//           };
//         }
//       } else if (response.statusCode == 401) {
//         final body = jsonDecode(response.body);
//         return {
//           'success': false,
//           'message': body['message'] ?? 'Invalid credentials'
//         };
//       } else if (response.statusCode == 422) {
//         final body = jsonDecode(response.body);
//         return {
//           'success': false,
//           'message': body['message'] ?? 'Validation failed'
//         };
//       } else {
//         final body = jsonDecode(response.body);
//         return {
//           'success': false,
//           'message': body['message'] ?? 'Login failed. Please try again.'
//         };
//       }
//     } catch (e) {
//       print('Login error: $e');
//       return {
//         'success': false,
//         'message': 'Network error. Please check your connection and try again.'
//       };
//     }
//   }
//
//   // Check session and redirect if needed
//   static Future<bool> checkAndHandleSession(BuildContext context, {String loginRoute = '/login'}) async {
//     try {
//       bool isValid = await isTokenValid();
//       if (!isValid) {
//         await clearTokens();
//
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Session expired. Please login again."),
//               backgroundColor: Colors.red,
//             ),
//           );
//
//           Navigator.of(context).pushNamedAndRemoveUntil(
//             '/login',
//                 (route) => false,
//           );
//         }
//         return false;
//       }
//       return true;
//     } catch (e) {
//       print('Session check error: $e');
//       return false;
//     }
//   }
//
//   // Logout
//   static Future<void> logout(BuildContext context, {String loginRoute = '/login'}) async {
//     try {
//       await clearTokens();
//
//       // Delay ensures tokens are actually cleared before next screen builds
//       await Future.delayed(Duration(milliseconds: 300));
//
//       if (context.mounted) {
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           loginRoute,
//               (route) => false,
//         );
//       }
//     } catch (e) {
//       print('Logout error: $e');
//     }
//   }
//
//
//   // Get headers with authorization
//   static Future<Map<String, String>> getAuthHeaders() async {
//     String? token = await getToken();
//     return {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }
// }