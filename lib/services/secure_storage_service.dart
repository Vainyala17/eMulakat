import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Alternative to flutter_secure_storage using SharedPreferences with encryption
class SecureStorageService {
  static const String _encryptionKey = 'eMulakat_encryption_key_2025'; // Change this to something unique

  /// Encrypt text using simple XOR cipher
  static String _encrypt(String text) {
    try {
      final textBytes = utf8.encode(text);
      final keyBytes = utf8.encode(_encryptionKey);
      final encryptedBytes = <int>[];

      for (int i = 0; i < textBytes.length; i++) {
        encryptedBytes.add(textBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64Encode(encryptedBytes);
    } catch (e) {
      print('❌ Encryption error: $e');
      return text; // Return plain text as fallback
    }
  }

  /// Decrypt text using simple XOR cipher
  static String _decrypt(String encryptedText) {
    try {
      final encryptedBytes = base64Decode(encryptedText);
      final keyBytes = utf8.encode(_encryptionKey);
      final decryptedBytes = <int>[];

      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decryptedBytes);
    } catch (e) {
      print('❌ Decryption error: $e');
      return encryptedText; // Return encrypted text as fallback
    }
  }

  /// Write encrypted value to SharedPreferences
  static Future<void> write({required String key, required String value}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedValue = _encrypt(value);
      await prefs.setString('secure_$key', encryptedValue);
      print('🔐 Stored encrypted data for key: $key');
    } catch (e) {
      print('❌ Error writing to secure storage: $e');
    }
  }

  /// Read and decrypt value from SharedPreferences
  static Future<String?> read({required String key}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedValue = prefs.getString('secure_$key');

      if (encryptedValue != null) {
        final decryptedValue = _decrypt(encryptedValue);
        print('🔓 Retrieved encrypted data for key: $key');
        return decryptedValue;
      }

      return null;
    } catch (e) {
      print('❌ Error reading from secure storage: $e');
      return null;
    }
  }

  /// Delete value from SharedPreferences
  static Future<void> delete({required String key}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('secure_$key');
      print('🗑️ Deleted data for key: $key');
    } catch (e) {
      print('❌ Error deleting from secure storage: $e');
    }
  }

  /// Clear all secure data
  static Future<void> deleteAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('secure_')).toList();

      for (String key in keys) {
        await prefs.remove(key);
      }

      print('🗑️ Cleared all secure storage data');
    } catch (e) {
      print('❌ Error clearing secure storage: $e');
    }
  }

  /// Check if key exists
  static Future<bool> containsKey({required String key}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('secure_$key');
    } catch (e) {
      print('❌ Error checking key existence: $e');
      return false;
    }
  }
}