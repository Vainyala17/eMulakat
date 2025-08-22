import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:eMulakat/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceService {
  static const String FINGERPRINT_KEY = 'device_fingerprint';
  static const String APP_KEY = 'app_key';
  static const String DEVICE_INFO_KEY = 'detailed_device_info';

  /// Get device information as User-Agent string
  static Future<String> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String userAgent = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        userAgent = '${androidInfo.version.release} ${androidInfo.version.sdkInt} - ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        userAgent = '${iosInfo.systemName} ${iosInfo.systemVersion} - ${iosInfo.model}';
      }

      print('📱 Device Info: $userAgent');
      return userAgent;
    } catch (e) {
      print('❌ Error getting device info: $e');
      return 'Unknown Device';
    }
  }

  /// Get or generate device fingerprint
  static Future<String> getDeviceFingerprint() async {
    try {
      // Check if fingerprint already exists
      final cached = await SecureStorageService.read(key: FINGERPRINT_KEY);
      if (cached != null && cached.isNotEmpty) {
        print('🔍 Using cached fingerprint: ${cached.substring(0, 10)}...');
        return cached;
      }

      // Generate new fingerprint
      final deviceInfo = DeviceInfoPlugin();
      String rawId = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        rawId = androidInfo.id ?? '';

        // Fallback if id is null or empty
        if (rawId.isEmpty) {
          rawId = '${androidInfo.model}-${androidInfo.brand}-${DateTime.now().millisecondsSinceEpoch}';
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        rawId = iosInfo.identifierForVendor ?? '';

        // Fallback if identifierForVendor is null or empty
        if (rawId.isEmpty) {
          rawId = '${iosInfo.model}-${iosInfo.systemName}-${DateTime.now().millisecondsSinceEpoch}';
        }
      }

      // Create SHA256 hash of rawId
      final bytes = utf8.encode(rawId);
      final digest = sha256.convert(bytes);
      final fingerprint = digest.toString();

      // Store fingerprint securely
      await SecureStorageService.write(key: FINGERPRINT_KEY, value: fingerprint);

      print('🔐 Generated new fingerprint: ${fingerprint.substring(0, 10)}...');
      return fingerprint;
    } catch (e) {
      print('❌ Error generating fingerprint: $e');
      // Return a fallback fingerprint based on timestamp
      final fallback = sha256.convert(utf8.encode('fallback-${DateTime.now().millisecondsSinceEpoch}')).toString();
      await SecureStorageService.write(key: FINGERPRINT_KEY, value: fallback);
      return fallback;
    }
  }

  /// Generate app key (equivalent to React Native version)
  static String generateAppKey() {
    // Replace these with your actual values
    const String ORDER_ID = "your_order_id";
    const String ORDER_DATE = "your_order_date";
    const String APP_NAME = "eMulakat";

    final raw = '$ORDER_ID|$ORDER_DATE|$APP_NAME';
    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    final appKey = digest.toString();

    print('🔧 Raw String: $raw');
    print('🔑 Generated app_key: ${appKey.substring(0, 10)}...');

    return appKey;
  }

  /// Store app key securely
  static Future<void> storeAppKey(String appKey) async {
    await SecureStorageService.write(key: APP_KEY, value: appKey);
    print('💾 App key stored securely');
  }

  /// Get stored app key
  static Future<String?> getStoredAppKey() async {
    return await SecureStorageService.read(key: APP_KEY);
  }

  /// Get complete device details (for debugging/logging) and STORE them
  static Future<Map<String, dynamic>> getDetailedDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> details = {};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        details = {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'androidId': androidInfo.id,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'fingerprint': await getDeviceFingerprint(),
          'appKey': await getStoredAppKey() ?? 'Not Generated',
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        details = {
          'platform': 'iOS',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'fingerprint': await getDeviceFingerprint(),
          'appKey': await getStoredAppKey() ?? 'Not Generated',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      // 🔥 STORE device info securely
      await SecureStorageService.write(
          key: DEVICE_INFO_KEY,
          value: json.encode(details)
      );

      // 🔥 CONSOLE LOGGING - Print stored device info
      print('');
      print('🔍 ===== DEVICE INFORMATION STORED =====');
      print('📱 Platform: ${details['platform']}');
      print('🏷️ Model: ${details['model']}');
      if (details['platform'] == 'Android') {
        print('🏭 Manufacturer: ${details['manufacturer']}');
        print('🔖 Brand: ${details['brand']}');
        print('📋 Device: ${details['device']}');
        print('🤖 Android Version: ${details['androidVersion']}');
        print('📊 SDK Int: ${details['sdkInt']}');
        print('🆔 Android ID: ${details['androidId']}');
      } else if (details['platform'] == 'iOS') {
        print('📛 Name: ${details['name']}');
        print('🍎 System: ${details['systemName']} ${details['systemVersion']}');
        print('🆔 Vendor ID: ${details['identifierForVendor']}');
      }
      print('📱 Physical Device: ${details['isPhysicalDevice']}');
      print('🔐 Fingerprint: ${details['fingerprint']?.toString().substring(0, 16)}...');
      print('🔑 App Key: ${details['appKey']?.toString().substring(0, 16)}...');
      print('⏰ Timestamp: ${details['timestamp']}');
      print('💾 Device info stored securely in encrypted storage');
      print('===== END DEVICE INFO =====');
      print('');

      return details;
    } catch (e) {
      print('❌ Error getting detailed device info: $e');
      return {'error': e.toString()};
    }
  }

  /// 🔥 NEW: Get stored device information
  static Future<Map<String, dynamic>?> getStoredDeviceInfo() async {
    try {
      final storedInfo = await SecureStorageService.read(key: DEVICE_INFO_KEY);
      if (storedInfo != null) {
        final deviceInfo = json.decode(storedInfo) as Map<String, dynamic>;

        // 🔥 CONSOLE LOGGING when retrieved
        print('');
        print('🔍 ===== RETRIEVED STORED DEVICE INFO =====');
        print('📱 Platform: ${deviceInfo['platform']}');
        print('🏷️ Model: ${deviceInfo['model']}');
        print('🔐 Fingerprint: ${deviceInfo['fingerprint']?.toString().substring(0, 16)}...');
        print('⏰ Stored at: ${deviceInfo['timestamp']}');
        print('===== END RETRIEVED INFO =====');
        print('');

        return deviceInfo;
      }
      return null;
    } catch (e) {
      print('❌ Error reading stored device info: $e');
      return null;
    }
  }

  /// 🔥 NEW: Print all stored device info to console
  static Future<void> printStoredDeviceInfoToConsole() async {
    try {
      final storedInfo = await getStoredDeviceInfo();
      if (storedInfo != null) {
        print('');
        print('🔍 ===== COMPLETE STORED DEVICE INFO =====');
        storedInfo.forEach((key, value) {
          if (key == 'fingerprint' || key == 'appKey') {
            print('$key: ${value?.toString().substring(0, 20)}...');
          } else {
            print('$key: $value');
          }
        });
        print('===== END COMPLETE INFO =====');
        print('');
      } else {
        print('⚠️ No device info found in storage');
      }
    } catch (e) {
      print('❌ Error printing stored device info: $e');
    }
  }

  /// Clear stored fingerprint (for testing/reset)
  static Future<void> clearFingerprint() async {
    await SecureStorageService.delete(key: FINGERPRINT_KEY);
    print('🗑️ Fingerprint cleared');
  }

  /// Clear all stored data including device info
  static Future<void> clearAllStoredData() async {
    await SecureStorageService.deleteAll();
    print('🗑️ All stored data cleared');
  }

  /// 🔥 NEW: Clear only device info
  static Future<void> clearStoredDeviceInfo() async {
    await SecureStorageService.delete(key: DEVICE_INFO_KEY);
    print('🗑️ Stored device info cleared');
  }
}